# Like a child learning their parent's skills!
class Users::SessionsController < Devise::SessionsController
  before_action :configure_permitted_parameters, only: :create

  def create
    super do |resource|
      session[:current_organization_id] = params.dig(:user, :organization_id) if resource.persisted? # Did they actually get logged in?
    end
  end

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) do |u|
        u.permit(
          :email,
          :password,
          :organization_id
        )
      end
    end
end
