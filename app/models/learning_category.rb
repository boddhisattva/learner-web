# == Schema Information
#
# Table name: learning_categories
#
#  id                                                  :bigint           not null, primary key
#  deleted_at                                          :datetime
#  description(More about the Learning Category)       :text
#  name(Learning Category name)                        :string           not null
#  created_at                                          :datetime         not null
#  updated_at                                          :datetime         not null
#  creator_id(Learning Category created by user)       :bigint           not null
#  modifier_id(Learning Category last updated by user) :bigint           not null
#
# Indexes
#
#  index_learning_categories_on_creator_id   (creator_id)
#  index_learning_categories_on_deleted_at   (deleted_at)
#  index_learning_categories_on_modifier_id  (modifier_id)
#  index_learning_categories_on_name         (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (modifier_id => users.id)
#
class LearningCategory < ApplicationRecord
  acts_as_paranoid

  # TODO: Add relevant model
  validates :name, presence: true

  belongs_to :creator, class_name: "User"
  belongs_to :last_modifier, class_name: "User"
end
