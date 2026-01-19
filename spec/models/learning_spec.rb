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
require 'rails_helper'

RSpec.describe Learning, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:lesson) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:last_modifier).class_name('User') }
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:learning_categorizations).dependent(:destroy) }
    it { is_expected.to have_many(:categories).through(:learning_categorizations).source(:category).class_name('LearningCategory') }
  end

  describe 'membership counter integration' do
    it 'updates creator membership counter on lifecycle events' do
      user = create(:user, :with_organization_and_membership)
      organization = user.personal_organization
      membership = Membership.find_by(member: user, organization: organization)

      learning = create(:learning, creator: user, organization: organization)
      expect(membership.reload.learnings_count).to eq(1)

      learning.destroy
      expect(membership.reload.learnings_count).to eq(0)
    end
  end

  describe '#same_organization_as?' do
    let(:user) { create(:user, :with_organization_and_membership) }
    let(:organization) { user.personal_organization }
    let(:learning) { create(:learning, creator: user, organization: organization) }

    context 'when other has the same organization_id' do
      it 'returns true' do
        category = create(:learning_category, creator: user, organization: organization)

        expect(learning.same_organization_as?(category)).to be true
      end
    end

    context 'when other has a different organization_id' do
      it 'returns false' do
        other_organization = create(:organization, owner: create(:user))
        category = create(:learning_category, creator: create(:user), organization: other_organization)

        expect(learning.same_organization_as?(category)).to be false
      end
    end
  end
end
