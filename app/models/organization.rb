# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint           not null
#
# Indexes
#
#  index_organizations_on_name      (name) UNIQUE
#  index_organizations_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#

class Organization < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships
  validates :name, uniqueness: true
end
