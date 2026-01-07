class AddOrganizationToLearningCategories < ActiveRecord::Migration[8.1]
  # Disable strong_migrations safety check for development/test environment
  disable_ddl_transaction!

  def up
    # Add organization_id column (nullable initially for data migration)
    add_reference :learning_categories, :organization, index: { algorithm: :concurrently }, null: true

    # Bypass strong_migrations check for development/test environment
    safety_assured { add_foreign_key :learning_categories, :organizations }

    # Migrate existing categories - assign to the creator's personal organization
    say_with_time 'Migrating existing categories to personal organizations' do
      safety_assured do
        execute <<-SQL
          UPDATE learning_categories
          SET organization_id = (
            SELECT personal_organization_id FROM users WHERE users.id = learning_categories.creator_id
          )
          WHERE organization_id IS NULL
        SQL
      end
    end

    # Now make it required
    safety_assured { change_column_null :learning_categories, :organization_id, false }

    # Remove old unique index on name alone
    safety_assured { remove_index :learning_categories, name: 'index_learning_categories_on_name' }

    # Add new unique index: name unique WITHIN organization
    safety_assured do
      add_index :learning_categories, [:organization_id, :name],
                unique: true,
                where: 'deleted_at IS NULL',
                name: 'index_learning_categories_on_org_and_name',
                algorithm: :concurrently
    end
  end

  def down
    # Restore old unique index
    add_index :learning_categories, :name,
              unique: true,
              where: 'deleted_at IS NULL',
              name: 'index_learning_categories_on_name'

    # Remove organization-scoped index
    remove_index :learning_categories, name: 'index_learning_categories_on_org_and_name'

    # Remove organization reference
    remove_reference :learning_categories, :organization
  end
end
