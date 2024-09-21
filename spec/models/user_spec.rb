# == Schema Information
#
# Table name: users
#
#  id                             :bigint           not null, primary key
#  email(User email)              :string
#  name(User name)                :string
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
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end
end
