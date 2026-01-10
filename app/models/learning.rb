# frozen_string_literal: true

# == Schema Information
#
# Table name: learnings
#
#  id                                                              :bigint           not null, primary key
#  deleted_at                                                      :datetime
#  description(Learning lesson in more detail)                     :text
#  lesson(Learning lesson learnt)                                  :string           not null
#  visibility                                                      :integer          default(0), not null
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
