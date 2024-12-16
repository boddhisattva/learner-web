# frozen_string_literal: true

class NameUpdateError < StandardError; end

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      sign_in @user

      # Every user gets added to their own 'self' related organization on creation
      # TO DO: Come back to expore how to handle the below code if oragnization creation fails & add relevant spec
      @organization = Organization.create(members: [@user], name: @user.name)

      redirect_to learnings_index_path,
                  status: :see_other,
                  flash: { success: t('.welcome', name: @user.name) }
    else
      flash.now[:error] = @user.errors.full_messages
      render '/devise/registrations/new', status: :unprocessable_entity
    end
  end

  # TODO: Try to make this method shorter using extract refactoring & when adding specs related to raise NameUpdateError scenarios
  # rubocop:disable Metrics/AbcSize
  def update
    user_organization = current_user.own_organization

    ActiveRecord::Base.transaction do
      raise NameUpdateError unless current_user.update(user_params)

      if user_name_updated? && user_organization_name_update_failed?(user_organization)
        # TO DO: Come back to expore how to handle the below code if oragnization updation fails & add relevant spec
        raise NameUpdateError
      end

      flash[:success] = t('.success')
      redirect_to profile_path, status: :see_other
    end
  rescue NameUpdateError
    # TO DO: Come back to expore how to handle the below code if oragnization creation fails..
    # TO DO Continuation: ..we need to return relevant errors of failed oragnization creation in a relevant spec & add relevant spec
    flash.now[:error] = current_user.errors.full_messages.concat(user_organization.errors.full_messages)
    render :edit, status: :unprocessable_entity
  end
  # rubocop:enable Metrics/AbcSize

  private

    def user_name_updated?
      current_user.first_name_previously_changed? || current_user.last_name_previously_changed?
    end

    def user_organization_name_update_failed?(user_organization)
      !user_organization&.update(name: current_user.name)
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
end
