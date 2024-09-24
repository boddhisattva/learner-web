module ApplicationHelper
  def title
    return t("learner") unless content_for?(:title)

    "#{content_for(:title)} | #{t("learner")}"
  end
end
