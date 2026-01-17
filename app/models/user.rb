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
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true

  belongs_to :personal_organization, class_name: 'Organization', optional: true

  has_many :memberships, dependent: :destroy, foreign_key: 'member_id', inverse_of: :member
  has_many :learnings, dependent: :destroy, foreign_key: 'creator_id', inverse_of: :creator
  has_many :learning_categories, dependent: :destroy, foreign_key: 'creator_id', inverse_of: :creator

  has_many :organizations, through: :memberships

  def name
    "#{first_name} #{last_name}"
  end

  def generate_unique_organization_name
    base_name = name

    existing_names = Organization.where('name = ? OR name LIKE ?', base_name, "#{base_name} %").pluck(:name).to_set

    return base_name unless existing_names.include?(base_name)

    counter = 2
    loop do
      candidate_name = "#{base_name} #{counter}"
      return candidate_name unless existing_names.include?(candidate_name)

      counter += 1
    end
  end
end
