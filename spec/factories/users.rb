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
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    first_name { "Rachel" }
    last_name { "Longwood" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password { "MyString" }
  end
end
