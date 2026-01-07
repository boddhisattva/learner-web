# frozen_string_literal: true

# == Schema Information
#
# Table name: learning_categorizations
#
#  id          :bigint           not null, primary key
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#  learning_id :bigint           not null
#
# Indexes
#
#  index_learning_categorizations_on_category_id  (category_id)
#  index_learning_categorizations_on_deleted_at   (deleted_at)
#  index_learning_categorizations_on_learning_id  (learning_id)
#  index_learning_categorizations_uniqueness      (learning_id,category_id) UNIQUE WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => learning_categories.id)
#  fk_rails_...  (learning_id => learnings.id)
#
FactoryBot.define do
  factory :learning_categorization do
    association :learning
    association :category, factory: :learning_category
  end
end
