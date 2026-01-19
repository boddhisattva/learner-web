# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                          :bigint           not null, primary key
#  email(User email)           :string           default(""), not null
#  encrypted_password          :string           default(""), not null
#  first_name(User first name) :string           not null
#  last_name(User last name)   :string           not null
#  remember_created_at         :datetime
#  reset_password_sent_at      :datetime
#  reset_password_token        :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  personal_organization_id    :bigint
#
# Indexes
#
#  index_users_on_email                     (email) UNIQUE
#  index_users_on_personal_organization_id  (personal_organization_id)
#  index_users_on_reset_password_token      (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (personal_organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }

    # TODO: Consider removing this. We might not need this explicit spec anymore after introducing devise as its inbuilt.
    describe 'unique case insensitive email' do
      let(:user) { create(:user, first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ') }

      before { user }

      context 'when same email(with a different case i.e., lower/upper) is used to create separate user records' do
        it 'does not allow saving upper & lower case versions of same email as separate user records' do
          other_user = described_class.new(first_name: 'Rachel', last_name: 'L', email: 'RACHEL@xyz.com ')

          expect(other_user.valid?).to be false
        end
      end
    end
  end

  describe '#name' do
    let(:user) do
      create(:user, password: 'test pass', first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ')
    end

    it 'returns user name' do
      expect(user.name).to eq('Rachel Longwood')
    end
  end

  describe '#generate_unique_organization_name' do
    it 'delegates to OrganizationNameGenerator service' do
      user = build(:user, first_name: 'John', last_name: 'Smith')
      generator = instance_double(OrganizationNameGenerator, generate_unique_name: 'John Smith')

      allow(OrganizationNameGenerator).to receive(:new).with('John Smith').and_return(generator)

      expect(user.generate_unique_organization_name).to eq('John Smith')
      expect(OrganizationNameGenerator).to have_received(:new).with('John Smith')
      expect(generator).to have_received(:generate_unique_name)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:personal_organization).class_name('Organization').optional }
    it { is_expected.to have_many(:memberships).with_foreign_key(:member_id).dependent(:destroy) }
    it { is_expected.to have_many(:organizations).through(:memberships) }
    it { is_expected.to have_many(:learnings).dependent(:destroy).with_foreign_key(:creator_id) }
    it { is_expected.to have_many(:learning_categories).dependent(:destroy).with_foreign_key(:creator_id) }
  end
end
