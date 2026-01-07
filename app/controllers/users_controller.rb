# frozen_string_literal: true

class NameUpdateError < StandardError; end

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if create_user_with_organization
      handle_successful_creation
    else
      handle_failed_creation
    end
  rescue StandardError => e
    handle_creation_error(e)
  end

  # TODO: Try to make this method shorter using extract refactoring & when adding specs related to raise NameUpdateError scenarios
  # rubocop:disable Metrics/AbcSize
  def update
    user_organization = current_user.personal_organization

    ActiveRecord::Base.transaction do
      raise NameUpdateError unless current_user.update(user_params)

      raise NameUpdateError if user_name_updated? && user_organization_name_update_failed?(user_organization)

      flash[:success] = t('.success')
      redirect_to profile_path, status: :see_other
    end
  rescue NameUpdateError
    flash.now[:error] = current_user.errors.full_messages.concat(user_organization.errors.full_messages)
    render :edit, status: :unprocessable_entity
  end
  # rubocop:enable Metrics/AbcSize

  private

    def user_name_updated?
      current_user.first_name_previously_changed? || current_user.last_name_previously_changed?
    end

    def user_organization_name_update_failed?(user_organization)
      !user_organization&.update!(name: current_user.name)
    rescue ActiveRecord::RecordInvalid => e
      user_organization.errors.merge!(e.record.errors)
      true
    rescue ActiveRecord::RecordNotUnique => e
      user_organization.errors.add(:name, e.message)
      true
    rescue StandardError => e
      user_organization.errors.add(:name, e.message)
      true
    end

    def handle_successful_creation
      sign_in @user
      redirect_to learnings_path,
                  status: :see_other,
                  flash: { success: t('.welcome', name: @user.name) }
    end

    def handle_failed_creation
      flash.now[:error] = @user.errors.full_messages
      render '/devise/registrations/new', status: :unprocessable_entity
    end

    def handle_creation_error(error)
      Rails.logger.error "User creation failed: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
      flash.now[:error] = ["Error: #{error.message}. Please try again."]
      render '/devise/registrations/new', status: :unprocessable_entity
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

    def create_user_with_organization
      ActiveRecord::Base.transaction do
        return false unless @user.save

        organization = Organization.create!(name: @user.name, owner: @user)

        @user.update!(personal_organization: organization)

        Membership.create!(member: @user, organization: organization)

        true
      end
    rescue ActiveRecord::RecordInvalid => e
      @user.errors.add(:base, "Organization: #{e.record.errors.full_messages.join(', ')}") if e.record.is_a?(Organization)
      false
    rescue ActiveRecord::RecordNotUnique
      @user.errors.add(:base, 'An organization with this name already exists')
      false
    end
end
