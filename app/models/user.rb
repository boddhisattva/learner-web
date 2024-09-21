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
class User < ApplicationRecord
  validates :name, presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
  uniqueness: { case_sensitive: false }
end
