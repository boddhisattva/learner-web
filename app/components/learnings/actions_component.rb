# frozen_string_literal: true

module Learnings
  class ActionsComponent < ViewComponent::Base
    # rubocop:disable Lint/MissingSuper
    def initialize(learning:)
      @learning = learning
    end
    # rubocop:enable Lint/MissingSuper

    private

      attr_reader :learning
  end
end
