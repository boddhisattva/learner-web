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
FactoryBot.define do
  factory :user do
    name { "MyString" }
    email { "MyString" }
    password_digest { "MyString" }
  end
end
