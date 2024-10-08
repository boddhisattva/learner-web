# == Schema Information
#
# Table name: users
#
#  id                          :bigint           not null, primary key
#  email(User email)           :string
#  encrypted_password          :string           default(""), not null
#  first_name(User first name) :string           not null
#  last_name(User last name)   :string           not null
#  remember_created_at         :datetime
#  reset_password_sent_at      :datetime
#  reset_password_token        :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    #  rubocop:disable Layout/LineLength
    # TODO: Consider removing this. We might not need this explicit spec anymore after introducing devise as its inbuilt.
    #  rubocop:enable Layout/LineLength
    describe 'unique case insensitive email' do
      let(:user) { create(:user, first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ') }

      before { user }

      context 'when same email(with a different case i.e., lower/upper) is used to create separate user records' do
        it 'does not allow saving upper & lower case versions of same email as separate user records' do
          other_user = User.new(first_name: 'Rachel', last_name: 'L', email: 'RACHEL@xyz.com ')

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
end
