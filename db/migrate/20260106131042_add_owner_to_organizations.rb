# frozen_string_literal: true

class AddOwnerToOrganizations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :organizations, :owner, null: true, index: { algorithm: :concurrently }
    add_foreign_key :organizations, :users, column: :owner_id, validate: false
  end
end
