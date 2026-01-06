# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_organization

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
  end

  private

    def current_organization
      @current_organization ||= find_current_organization
    end

    def current_membership
      @current_membership ||= find_current_membership
    end

    def find_current_organization
      return nil unless current_user

      if session[:current_organization_id]
        org = current_user.organizations.find_by(id: session[:current_organization_id])
        return org if org.present?
      end

      org = current_user.personal_organization
      org.presence
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
