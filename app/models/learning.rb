# frozen_string_literal: true

# == Schema Information
#
# Table name: learnings
#
#  id                                                              :bigint           not null, primary key
#  deleted_at                                                      :datetime
#  description(Learning lesson in more detail)                     :text
#  lesson(Learning lesson learnt)                                  :string           not null
#  visibility                                                      :integer          default("personal"), not null
#  created_at                                                      :datetime         not null
#  updated_at                                                      :datetime         not null
#  creator_id(User who created the learning)                       :bigint           not null
#  last_modifier_id(User who last modified the learning)           :bigint           not null
#  organization_id(The organization to which the learning belongs) :bigint           not null
#
# Indexes
#
#  index_learnings_on_creator_id                      (creator_id)
#  index_learnings_on_creator_id_and_organization_id  (creator_id,organization_id)
#  index_learnings_on_deleted_at                      (deleted_at)
#  index_learnings_on_last_modifier_id                (last_modifier_id)
#  index_learnings_on_lesson                          (lesson)
#  index_learnings_on_organization_id                 (organization_id)
#  index_learnings_on_visibility_and_org_id           (visibility,organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (last_modifier_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Learning < ApplicationRecord
  # TODO: Remove this L36 line in 1-2 days as Rails caches column information that was used earlier
  # Hence safer to remove this in a few days
  self.ignored_columns = %w[learning_category_ids]
  acts_as_paranoid

  validates :lesson, presence: true

  # Broadcast CREATE operations (prepend new learning to page 1)
  broadcasts_to ->(learning) { "learnings_org_#{learning.organization_id}" },
                inserts_by: :prepend,
                target: 'learning_page_1',
                if: :broadcastable?

  # Broadcast UPDATE operations (replace or remove based on visibility changes)
  after_update_commit :broadcast_visibility_change

  # Broadcast DESTROY operations (remove the learning from the list)
  after_destroy_commit -> { broadcast_remove_to_organization if was_broadcastable_before_destroy? }

  enum :visibility, {
    personal: 0, # Only visible to the creator
    organization: 1,
    open: 2 # Open to public/all
  }

  belongs_to :creator, class_name: 'User'
  belongs_to :last_modifier, class_name: 'User'
  belongs_to :organization

  has_many :learning_categorizations, dependent: :destroy
  has_many :categories, through: :learning_categorizations, source: :category, class_name: 'LearningCategory'

  # Counter cache for membership learnings_count
  after_create :increment_membership_counter
  after_destroy :decrement_membership_counter
  after_restore :increment_membership_counter

  def self.search(query)
    where('lesson ILIKE ?', "%#{query}%")
  end

  private

    def broadcastable?
      organization_id.present? && (open? || organization?)
    end

    def was_broadcastable?(visibility_value)
      %w[organization open].include?(visibility_value)
    end

    def was_broadcastable_before_destroy?
      # For destroy, check current state before deletion
      broadcastable?
    end

    def broadcast_visibility_change
      # Check if visibility changed
      if saved_change_to_visibility?
        old_visibility = visibility_before_last_save
        new_visibility = visibility

        was_broadcastable_before = was_broadcastable?(old_visibility)
        is_broadcastable_now = broadcastable?

        if was_broadcastable_before && !is_broadcastable_now
          # Changed from organization/open → personal
          # Remove from other users' views
          broadcast_remove_to_organization
        elsif is_broadcastable_now
          # Is currently organization/open
          # Replace/update in views (works for both update and personal→org/open changes)
          broadcast_replace_to_organization
        end
        # If was personal and still personal, do nothing
      elsif broadcastable?
        # Visibility didn't change but other fields did, and it's broadcastable
        broadcast_replace_to_organization
      end
    end

    def broadcast_replace_to_organization
      broadcast_replace_to(
        "learnings_org_#{organization_id}",
        target: self,
        partial: 'learnings/learning',
        locals: { learning: self }
      )
    end

    def broadcast_remove_to_organization
      broadcast_remove_to(
        "learnings_org_#{organization_id}",
        target: self
      )
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

    def decrement_membership_counter
      update_membership_counter(-1)
    end

    def find_creator_membership
      Membership.find_by(
        member_id: creator_id,
        organization_id: organization_id
      )
    end
end
