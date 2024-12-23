# frozen_string_literal: true

class AddMemberOrganizationUniqueConstraintToMembership < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :memberships, %i[member_id organization_id], unique: true, algorithm: :concurrently
  end
end
