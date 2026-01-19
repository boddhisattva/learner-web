# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_organization

  helper_method :current_organization

  def after_sign_in_path_for(_resource)
    learnings_path
  end

  unless Rails.env.production?
    # N+1 query detection using prosopite gem
    around_action :n_plus_one_detection

    def n_plus_one_detection
      Prosopite.scan
      yield
    ensure
      Prosopite.finish
    end

    def skip_bullet
      previous_value = Bullet.enable?
      Bullet.enable = false
      yield
    ensure
      Bullet.enable = previous_value
    end
  end

  private

    def current_organization
      @current_organization ||= CurrentOrganizationResolver.new(current_user, session).resolve
    end

    def current_membership
      @current_membership ||= find_current_membership
    end

    def find_current_membership
      return nil unless current_organization

      current_user.memberships.find_by(organization_id: current_organization.id)
    end

    def set_current_organization
      # Store in session for next request
      session[:current_organization_id] = current_organization&.id
    end
end
