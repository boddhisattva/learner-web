# frozen_string_literal: true

module MembershipCounterUpdater
  extend ActiveSupport::Concern

  included do
    before_real_destroy :mark_as_being_really_destroyed
    after_create :increment_membership_counter
    after_destroy :decrement_on_soft_delete
    after_restore :increment_membership_counter
    after_real_destroy :decrement_on_real_destroy
  end

  private

    def mark_as_being_really_destroyed
      @being_really_destroyed = true
      @was_already_soft_deleted_before_real_destroy = deleted_at_was.present?
    end

    def update_membership_counter(count_change)
      # rubocop:disable Rails/SkipsModelValidations
      membership = find_creator_membership
      Membership.update_counters(membership.id, learnings_count: count_change) if membership
      # rubocop:enable Rails/SkipsModelValidations
    end

    def increment_membership_counter
      update_membership_counter(1)
    end

    def decrement_on_soft_delete
      return if @being_really_destroyed

      update_membership_counter(-1)
    end

    def decrement_on_real_destroy
      return if @was_already_soft_deleted_before_real_destroy

      update_membership_counter(-1)
    end

    def find_creator_membership
      Membership.find_by(
        member_id: creator_id,
        organization_id: organization_id
      )
    end
end
