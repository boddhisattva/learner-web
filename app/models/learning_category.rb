# frozen_string_literal: true

# == Schema Information
#
# Table name: learning_categories
#
#  id                                                             :bigint           not null, primary key
#  deleted_at                                                     :datetime
#  description(More information about the learning category)      :text
#  name(Name of the learning category)                            :string           not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  creator_id(User who created the learning category)             :bigint           not null
#  last_modifier_id(User who last modified the learning category) :bigint           not null
#  organization_id                                                :bigint           not null
#
# Indexes
#
#  index_learning_categories_on_creator_id        (creator_id)
#  index_learning_categories_on_deleted_at        (deleted_at)
#  index_learning_categories_on_last_modifier_id  (last_modifier_id)
#  index_learning_categories_on_org_and_name      (organization_id,name) UNIQUE WHERE (deleted_at IS NULL)
#  index_learning_categories_on_organization_id   (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (last_modifier_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#

class LearningCategory < ApplicationRecord
  acts_as_paranoid

  belongs_to :organization
  belongs_to :creator, class_name: 'User'
  belongs_to :last_modifier, class_name: 'User'

  validates :name, presence: true,
                   uniqueness: {
                     scope: :organization_id,
                     conditions: -> { where(deleted_at: nil) },
                     message: 'already exists in this organization'
                   }

  has_many :learning_categorizations, foreign_key: :category_id, dependent: :destroy, inverse_of: :category
  has_many :learnings, through: :learning_categorizations
end
