class AddPersonalOrganizationToUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :users, :personal_organization, null: true, index: { algorithm: :concurrently }
    add_foreign_key :users, :organizations, column: :personal_organization_id, validate: false
  end
end
