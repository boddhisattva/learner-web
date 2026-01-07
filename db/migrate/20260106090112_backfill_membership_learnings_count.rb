# frozen_string_literal: true

class BackfillMembershipLearningsCount < ActiveRecord::Migration[8.1]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    Membership.find_each do |membership|
      count = Learning.where(
        creator_id: membership.member_id,
        organization_id: membership.organization_id,
        deleted_at: nil
      ).count

      membership.update_column(:learnings_count, count)
    end
  end

  def down
    Membership.update_all(learnings_count: 0)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
