# frozen_string_literal: true

module Learnings
  class ActionsComponent < ViewComponent::Base
    def initialize(learning:)
      @learning = learning
    end

    private

      attr_reader :learning
  end
end
