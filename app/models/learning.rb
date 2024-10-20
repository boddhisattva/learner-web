# == Schema Information
#
# Table name: learnings
#
#  id                                                         :bigint           not null, primary key
#  deleted_at                                                 :datetime
#  description(More about the Learning description)           :text
#  lesson(What the Learning is about)                         :string           not null
#  public(Whether learning is to be publicly shared or not)   :boolean          default(FALSE), not null
#  created_at                                                 :datetime         not null
#  updated_at                                                 :datetime         not null
#  creator_id(Learning created by user)                       :bigint           not null
#  learning_category_id                                       :bigint           not null
#  modifier_id(Learning last updated by user)                 :bigint           not null
#  organization_id(Organization associated with the Learning) :bigint           not null
#
# Indexes
#
#  index_learnings_on_creator_id             (creator_id)
#  index_learnings_on_creator_id_and_lesson  (creator_id,lesson) UNIQUE
#  index_learnings_on_deleted_at             (deleted_at)
#  index_learnings_on_learning_category_id   (learning_category_id)
#  index_learnings_on_modifier_id            (modifier_id)
#  index_learnings_on_organization_id        (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (learning_category_id => learning_categories.id)
#  fk_rails_...  (modifier_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Learning < ApplicationRecord
  acts_as_paranoid

  # TODO: Add relevant model spec
  validates :lesson, presence: true

  belongs_to :creator, class_name: "User"
  belongs_to :last_modifier, class_name: "User"
  # belongs_to :learning_category
end
