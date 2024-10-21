class AddNameToOrganization < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :organizations, :name, :string, null: false
    add_index :organizations, :name, unique: true, algorithm: :concurrently
  end
end
