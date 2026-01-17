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
FactoryBot.define do
  factory :user do
    first_name { 'Person' }
    sequence(:last_name) { |n| "surname_#{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password { 'MyString' }

    trait :with_organization_and_membership do
      after(:create) do |user|
        organization = Organization.create!(name: user.name, owner: user)
        user.update!(personal_organization: organization)
        Membership.find_or_create_by!(member: user, organization: organization)
      end
    end
  end
end
