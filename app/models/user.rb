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
class User < ApplicationRecord
  has_secure_password

  before_validation :strip_extra_spaces

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
  uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 8 }

  def name
    "#{first_name} #{last_name}"
  end

  private

    def strip_extra_spaces
      self.first_name = self.first_name&.strip
      self.last_name = self.last_name&.strip
      self.email = self.email&.strip
    end
end
