# frozen_string_literal: true

# == Schema Information
#
# Table name: learnings
#
#  id                                                                                       :bigint           not null, primary key
#  deleted_at                                                                               :datetime
#  description(Learning lesson in more detail)                                              :text
#  learning_category_ids(Collection of different learning categories a Learning belongs to) :integer          default([]), is an Array
#  lesson(Learning lesson learnt)                                                           :string           not null
#  public_visibility(Determines organizational visibility of the learning)                  :boolean          default(FALSE), not null
#  created_at                                                                               :datetime         not null
#  updated_at                                                                               :datetime         not null
#  creator_id(User who created the learning)                                                :bigint           not null
#  last_modifier_id(User who last modified the learning)                                    :bigint           not null
#  organization_id(The organization to which the learning belongs)                          :bigint           not null
#
# Indexes
#
#  index_learnings_on_creator_id             (creator_id)
#  index_learnings_on_deleted_at             (deleted_at)
#  index_learnings_on_last_modifier_id       (last_modifier_id)
#  index_learnings_on_learning_category_ids  (learning_category_ids) USING gin
#  index_learnings_on_lesson                 (lesson)
#  index_learnings_on_organization_id        (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (last_modifier_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Learning < ApplicationRecord
  acts_as_paranoid

  validates :lesson, presence: true

  belongs_to :creator, class_name: 'User'
  belongs_to :last_modifier, class_name: 'User'
  belongs_to :organization

  def learning_categories
    LearningCategory.where(id: learning_category_ids)
  end
end
