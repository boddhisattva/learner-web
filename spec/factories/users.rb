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
FactoryBot.define do
  factory :user do
    first_name { "Rachel" }
    last_name { "Longwood" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password { "MyString" }
  end
end
