# frozen_string_literal: true

# == Schema Information
#
# Table name: learnings
#
#  id                                                              :bigint           not null, primary key
#  deleted_at                                                      :datetime
#  description(Learning lesson in more detail)                     :text
#  lesson(Learning lesson learnt)                                  :string           not null
#  visibility                                                      :integer          default("personal"), not null
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
#  index_learnings_on_organization_id                 (organization_id)
#  index_learnings_on_visibility_and_org_id           (visibility,organization_id)
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

  describe '#categories' do
    let(:user) { create(:user) }
    let(:organization) { user.personal_organization }
    let(:category) { create(:learning_category, creator: user, organization: organization) }
    let(:another_category) { create(:learning_category, creator: user, organization: organization) }
    let(:learning) { create(:learning, creator: user, organization: organization) }

    before do
      category
      another_category
      learning.update(category_ids: [category.id, another_category.id])
    end

    it 'returns the correct learning categories' do
      expect(learning.category_ids).to contain_exactly(category.id, another_category.id)
      expect(learning.categories).to contain_exactly(category, another_category)
    end
  end

  describe 'broadcasting behavior' do
    let(:user) { create(:user) }
    let(:organization) { user.personal_organization }
    let(:stream_name) { "learnings_org_#{organization.id}" }

    describe 'CREATE operations' do
      let(:personal_learning) do
        build(:learning, creator: user, last_modifier: user, organization: organization, visibility: :personal)
      end
      let(:org_learning) do
        build(:learning, creator: user, last_modifier: user, organization: organization, visibility: :organization)
      end
      let(:open_learning) do
        build(:learning, creator: user, last_modifier: user, organization: organization, visibility: :open)
      end

      it 'broadcasts open & organization learnings but not personal learnings' do
        expect { personal_learning.save! }.not_to have_broadcasted_to(stream_name)
        expect(personal_learning.persisted?).to be true

        expect { org_learning.save! }.to have_broadcasted_to(stream_name)
        expect(org_learning.persisted?).to be true

        expect { open_learning.save! }.to have_broadcasted_to(stream_name)
        expect(open_learning.persisted?).to be true
      end
    end

    describe 'UPDATE operations' do
      it 'broadcasts when changing from personal to open or organization visibility' do
        learning = create(:learning,
                          creator: user,
                          last_modifier: user,
                          organization: organization,
                          visibility: :personal)

        expect { learning.update!(visibility: :organization) }.to have_broadcasted_to(stream_name)
        expect(learning.reload.visibility).to eq('organization')

        learning.update!(visibility: :personal)

        expect { learning.update!(visibility: :open) }.to have_broadcasted_to(stream_name)
        expect(learning.reload.visibility).to eq('open')
      end

      it 'broadcasts when changing from open or organization to personal visibility' do
        org_learning = create(:learning,
                              creator: user,
                              last_modifier: user,
                              organization: organization,
                              visibility: :organization)

        expect { org_learning.update!(visibility: :personal) }.to have_broadcasted_to(stream_name)
        expect(org_learning.reload.visibility).to eq('personal')

        open_learning = create(:learning,
                               creator: user,
                               last_modifier: user,
                               organization: organization,
                               visibility: :open)

        expect { open_learning.update!(visibility: :personal) }.to have_broadcasted_to(stream_name)
        expect(open_learning.reload.visibility).to eq('personal')
      end

      it 'broadcasts when changing between open or organization visibility types' do
        learning = create(:learning,
                          creator: user,
                          last_modifier: user,
                          organization: organization,
                          visibility: :organization)

        expect { learning.update!(visibility: :open) }.to have_broadcasted_to(stream_name)
        expect(learning.reload.visibility).to eq('open')

        expect { learning.update!(visibility: :organization) }.to have_broadcasted_to(stream_name)
        expect(learning.reload.visibility).to eq('organization')
      end

      it 'broadcasts content updates for open or organization learnings but not personal' do
        org_learning = create(:learning, creator: user, last_modifier: user, organization: organization,
                                         visibility: :organization, lesson: 'Original lesson')
        expect { org_learning.update!(lesson: 'Updated org lesson') }.to have_broadcasted_to(stream_name)
        expect(org_learning.reload.lesson).to eq('Updated org lesson')

        open_learning = create(:learning, creator: user, last_modifier: user, organization: organization,
                                          visibility: :open, lesson: 'Original lesson')

        expect { open_learning.update!(lesson: 'Updated open lesson') }.to have_broadcasted_to(stream_name)
        expect(open_learning.reload.lesson).to eq('Updated open lesson')

        personal_learning = create(:learning,
                                   creator: user,
                                   last_modifier: user,
                                   organization: organization,
                                   visibility: :personal,
                                   lesson: 'Original lesson')

        expect { personal_learning.update!(lesson: 'Updated personal lesson') }.not_to have_broadcasted_to(stream_name)
        expect(personal_learning.reload.lesson).to eq('Updated personal lesson')
      end
    end

    describe 'DESTROY operations' do
      let(:personal_learning) do
        create(:learning, creator: user, last_modifier: user, organization: organization, visibility: :personal)
      end

      it 'broadcasts when destroying open or organization learnings but not personal' do
        org_learning = create(:learning, creator: user, last_modifier: user, organization: organization, visibility: :organization)
        open_learning = create(:learning, creator: user, last_modifier: user, organization: organization, visibility: :open)

        expect { org_learning.destroy! }.to have_broadcasted_to(stream_name)
        expect(org_learning.deleted_at).not_to be_nil

        expect { open_learning.destroy! }.to have_broadcasted_to(stream_name)
        expect(open_learning.deleted_at).not_to be_nil

        expect { personal_learning.destroy! }.not_to have_broadcasted_to(stream_name)
        expect(personal_learning.deleted_at).not_to be_nil
      end
    end
  end
end
