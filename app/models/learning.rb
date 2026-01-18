# frozen_string_literal: true

# == Schema Information
#
# Table name: learnings
#
#  id                                                              :bigint           not null, primary key
#  deleted_at                                                      :datetime
#  description(Learning lesson in more detail)                     :text
#  lesson(Learning lesson learnt)                                  :string           not null
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
#  index_learnings_on_lesson_trgm                     (lower((lesson)::text) gin_trgm_ops) USING gin
#  index_learnings_on_organization_id                 (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (last_modifier_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Learning < ApplicationRecord
  acts_as_paranoid

  include MembershipCounterUpdater

  validates :lesson, presence: true

  belongs_to :creator, class_name: 'User'
  belongs_to :last_modifier, class_name: 'User'
  belongs_to :organization

  has_many :learning_categorizations, dependent: :destroy
  has_many :categories, through: :learning_categorizations, source: :category, class_name: 'LearningCategory'

  def self.search(query)
    where('lower(lesson) LIKE lower(?)', "%#{sanitize_sql_like(query)}%")
  end
end
