# frozen_string_literal: true

class ValidateEnforceNotNullConstraintsForOrganisations < ActiveRecord::Migration[8.1]
  def up
    validate_foreign_key :organizations, :users, column: :owner_id

    validate_check_constraint :organizations, name: 'organizations_owner_id_null'

    change_column_null :organizations, :owner_id, false

    remove_check_constraint :organizations, name: 'organizations_owner_id_null'
  end

  def down
    change_column_null :organizations, :owner_id, true

    add_check_constraint :organizations, 'owner_id IS NOT NULL',
                         name: 'organizations_owner_id_null',
                         validate: false
  end
end
