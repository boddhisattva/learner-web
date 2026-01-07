# frozen_string_literal: true

class EnforceNotNullConstraintsForUserAndOrganisation < ActiveRecord::Migration[8.1]
  def change
    # Add check constraint (not validated yet) to prevent new NULL values
    # Setting validate: false allows the constraint to be added without blocking
    # writes to the organizations table or causing long table locks during deployment
    add_check_constraint :organizations, 'owner_id IS NOT NULL',
                         name: 'organizations_owner_id_null',
                         validate: false
  end
end
