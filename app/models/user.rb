# == Schema Information
#
# Table name: users
#
#  id                             :bigint           not null, primary key
#  email(User email)              :string
#  encrypted_password             :string           default(""), not null
#  first_name(User first name)    :string           not null
#  last_name(User last name)      :string           not null
#  password_digest(User password) :string
#  remember_created_at            :datetime
#  reset_password_sent_at         :datetime
#  reset_password_token           :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :strip_extra_spaces

  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  private

    def strip_extra_spaces # TODO: Devise seems to provide support for this through initializers/devise.rb come back and check later
      self.first_name = self.first_name&.strip
      self.last_name = self.last_name&.strip
      self.email = self.email&.strip
    end
end
