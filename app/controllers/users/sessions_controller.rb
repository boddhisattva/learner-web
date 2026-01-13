# frozen_string_literal: true

# Like a child learning their parent's skills!
module Users
  class SessionsController < Devise::SessionsController
    before_action :configure_permitted_parameters, only: :create

    def create
      super do |resource|
        # Did they actually get logged in?
        session[:current_organization_id] = params.dig(:user, :organization_id) if resource.persisted?
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
end
