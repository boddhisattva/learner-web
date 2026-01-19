# frozen_string_literal: true

class CurrentOrganizationResolver
  def initialize(user, session)
    @user = user
    @session = session
  end

  def resolve
    return nil unless @user

    find_from_session || find_personal_organization
  end

  private

    def find_from_session
      return nil unless @session[:current_organization_id]

      @user.organizations.find_by(id: @session[:current_organization_id])
    end

    def find_personal_organization
      @user.personal_organization
    end
end
