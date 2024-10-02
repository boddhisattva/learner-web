# == Schema Information
#
# Table name: memberships
#
#  rubocop:disable Layout/LineLength
#  id                                                                               :bigint           not null, primary key
#  rubocop:enable Layout/LineLength
#  created_at                                                                       :datetime         not null
#  updated_at                                                                       :datetime         not null
#  member_id(This references the user associated with the membership)               :bigint           not null
#  organization_id(This references the organisation associated with the membership) :bigint           not null
#
# Indexes
#
#  index_memberships_on_member_id        (member_id)
#  index_memberships_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe Membership, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
