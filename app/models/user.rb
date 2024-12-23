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

  validates :first_name, presence: true
  validates :last_name, presence: true

  # rubocop:disable Rails / InverseOf
  has_many :memberships, dependent: :destroy, foreign_key: 'member_id'
  has_many :learnings, dependent: :destroy, foreign_key: 'creator_id'
  has_many :learning_categories, dependent: :destroy, foreign_key: 'creator_id'
  # rubocop:enable Rails / InverseOf

  has_many :organizations, through: :memberships

  def name
    "#{first_name} #{last_name}"
  end

  # Add test for the same
  def own_organization
    Organization.where(name: self.name).first
  end
end
