# frozen_string_literal: true

class UserRegistration
  def initialize(user)
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      return false unless @user.save

      organization = create_personal_organization
      @user.update!(personal_organization: organization)
      create_membership

      true
    end
  rescue ActiveRecord::RecordInvalid => e
    add_error_to_user(e)
    false
  end

  private

    attr_reader :user

    def create_personal_organization
      Organization.create!(
        name: @user.generate_unique_organization_name,
        owner: @user
      )
    end

    def create_membership
      Membership.create!(
        member: @user,
        organization: @user.personal_organization
      )
    end

    def add_error_to_user(exception_instance)
      record = exception_instance.record
      record_type = record.class.name

      @user.errors.add(:base, "#{record_type} failed: #{record.errors.full_messages.join(', ')}")
    end
end
