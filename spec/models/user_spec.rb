# == Schema Information
#
# Table name: users
#
#  id                             :bigint           not null, primary key
#  email(User email)              :string
#  first_name(User first name)    :string           not null
#  last_name(User last name)      :string           not null
#  password_digest(User password) :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(8) }

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

  describe '#strip_extra_spaces' do
    let(:user) {
 create(:user, password: 'test pass', first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ') }

    it 'removes the extra spaces from first name, last name & email' do
      user.save

      expect(user.first_name).to eq('Rachel')
      expect(user.email).to eq('rachel@xyz.com')
    end
  end
end
