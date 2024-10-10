class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :turbo_native_app?

  def after_sign_in_path_for(resource)
    feed_index_path
  end
end
