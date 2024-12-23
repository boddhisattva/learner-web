# frozen_string_literal: true

class AddNameToOrganization < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  # rubocop:disable Rails / NotNullColumn
  def change
    add_column :organizations, :name, :string, null: false
    add_index :organizations, :name, unique: true, algorithm: :concurrently
  end
  # rubocop:enable Rails / NotNullColumn
end
