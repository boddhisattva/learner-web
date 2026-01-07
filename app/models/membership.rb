# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id                                                                               :bigint           not null, primary key
#  learnings_count(Counter cache for learnings count per user per organization)     :integer          default(0), not null
#  created_at                                                                       :datetime         not null
#  updated_at                                                                       :datetime         not null
#  member_id(This references the user associated with the membership)               :bigint           not null
#  organization_id(This references the organisation associated with the membership) :bigint           not null
#
# Indexes
#
#  index_memberships_on_member_id                      (member_id)
#  index_memberships_on_member_id_and_organization_id  (member_id,organization_id) UNIQUE
#  index_memberships_on_organization_id                (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#

class Membership < ApplicationRecord
  belongs_to :member, class_name: 'User'
  belongs_to :organization
end
