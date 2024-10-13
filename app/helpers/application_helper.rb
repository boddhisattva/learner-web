module ApplicationHelper
  def title
    return t("learner") unless content_for?(:title)

    # TODO: Test this manually later once you continue development for the mobile native app
    return content_for(:title) if turbo_native_app?

    "#{content_for(:title)} | #{t("learner")}"
  end
end
