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
require 'rails_helper'

RSpec.describe Learning, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:lesson) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:last_modifier).class_name('User') }
    it { is_expected.to belong_to(:organization) }
  end

  describe '#learning_categories' do
    let(:category) { create(:learning_category) }
    let(:another_category) { create(:learning_category) }
    let(:learning) { create(:learning) }

    before do
      category
      another_category
      learning.update(learning_category_ids: [category.id, another_category.id])
    end

    it 'returns the correct learning categories' do
      expect(learning.learning_category_ids).to contain_exactly(category.id, another_category.id)
    end
  end
end
