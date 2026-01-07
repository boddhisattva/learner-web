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
require 'rails_helper'

RSpec.describe LearningCategorization, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:learning) }
    it { is_expected.to belong_to(:category).class_name('LearningCategory') }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization, owner: user) }
    let(:learning) { create(:learning, creator: user, organization: organization) }
    let(:category) { create(:learning_category, creator: user, organization: organization) }

    describe 'category_belongs_to_same_organization' do
      it 'validates that category belongs to same organization as learning' do
        other_org = create(:organization)
        other_category = create(:learning_category, organization: other_org)

        categorization = build(:learning_categorization, learning: learning, category: other_category)

        expect(categorization).not_to be_valid
        expect(categorization.errors[:category]).to include('must belong to the same organization as the learning')
      end

      it 'allows categorization when category belongs to same organization as learning' do
        categorization = build(:learning_categorization, learning: learning, category: category)

        expect(categorization).to be_valid
      end
    end

    describe 'uniqueness validation' do
      it 'prevents duplicate categorizations for the same learning and category' do
        create(:learning_categorization, learning: learning, category: category)
        categorization2 = build(:learning_categorization, learning: learning, category: category)

        expect(categorization2).not_to be_valid
        expect(categorization2.errors[:learning_id]).to include('already has this category')
      end

      it 'allows the same category for different learnings' do
        learning2 = create(:learning, creator: user, organization: organization)

        create(:learning_categorization, learning: learning, category: category)
        categorization2 = build(:learning_categorization, learning: learning2, category: category)

        expect(categorization2).to be_valid
      end

      it 'allows different categories for the same learning' do
        category2 = create(:learning_category, name: 'Another Category', creator: user, organization: organization)

        create(:learning_categorization, learning: learning, category: category)
        categorization2 = build(:learning_categorization, learning: learning, category: category2)

        expect(categorization2).to be_valid
      end
    end
  end
end
