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

require 'rails_helper'

RSpec.describe LearningCategory, type: :model do
  subject { build(:learning_category) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id).with_message('already exists in this organization') }
  end

  describe 'uniqueness validation with paranoia' do
    let(:user) { create(:user, :with_organization_and_membership) }
    let(:organization) { user.personal_organization }
    let(:other_organization) { create(:organization, owner: create(:user)) }

    context 'when name exists in same organization' do
      it 'does not allow duplicate name in the same organization' do
        create(:learning_category, name: 'Category Name', creator: user, organization: organization)
        duplicate = build(:learning_category, name: 'Category Name', creator: user, organization: organization)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include('already exists in this organization')
      end
    end

    context 'when name exists in different organization' do
      it 'allows same name in different organization' do
        create(:learning_category, name: 'Category Name', creator: user, organization: organization)
        category_in_other_org = build(:learning_category, name: 'Category Name', creator: other_organization.owner,
                                                          organization: other_organization)

        expect(category_in_other_org).to be_valid
      end
    end

    context 'when a soft-deleted category with same name exists' do
      it 'allows creating a category with the same name' do
        existing_category = create(:learning_category, name: 'Category Name', creator: user, organization: organization)
        existing_category.destroy

        new_category = build(:learning_category, name: 'Category Name', creator: user, organization: organization)
        expect(new_category).to be_valid
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:last_modifier).class_name('User') }
  end
end
