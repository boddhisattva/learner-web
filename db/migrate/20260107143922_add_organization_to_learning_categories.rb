# frozen_string_literal: true

class AddOrganizationToLearningCategories < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_organization_column     # Step1: Create the organization_id column(like adding a new drawer to a filing cabinet)
    migrate_existing_categories # Step2: Fill in organization_id for existing categories(putting files in the new drawer)
    add_not_null_constraint     # Step3: Create a rule that organization_id must exist, but don't enforce yet(writing rule on paper)
    validate_not_null_constraint # Step4: Check that all categories follow the rule(verifying everyone has filed correctly)
    make_organization_required  # Step5: Make organization_id required in the database(officially enforcing the rule)
    cleanup_constraint          # Step6: Remove the temporary rule from Step 3(throwing away the paper, rule is now official)
    update_indexes              # Step7: Update search indexes to make lookups fast(creating a new index card system)
  end

  def down
    restore_old_index
    remove_organization_reference
  end

  private

    def add_organization_column
      return if column_exists?(:learning_categories, :organization_id)

      # Add organization_id column (nullable initially for data migration)
      add_reference :learning_categories, :organization, index: { algorithm: :concurrently }, null: true

      # Add foreign key without validation (fast, no lock)
      safety_assured do
        add_foreign_key :learning_categories, :organizations, validate: false
      end

      # Validate FK separately: ensures all organization_ids point to real organizations (checks data integrity without locking table)
      safety_assured do
        validate_foreign_key :learning_categories, :organizations
      end
    end

    def migrate_existing_categories
      # Migrate existing categories - assign to the creator's personal organization
      say_with_time 'Migrating existing categories to personal organizations' do
        # Not batching this update as it's currently not a large table
        # safety_assured is needed because strong_migrations can't inspect execute statements
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
    end

    def add_not_null_constraint
      # Skip if constraint already exists (idempotent migration)
      constraint_exists = safety_assured do
        execute(<<-SQL).to_a.any?
          SELECT 1 FROM pg_constraint
          WHERE conname = 'learning_categories_organization_id_null'
        SQL
      end
      return if constraint_exists

      # Add NOT NULL constraint without validation (instant, no lock)
      safety_assured do
        execute <<-SQL
          ALTER TABLE learning_categories
          ADD CONSTRAINT learning_categories_organization_id_null
          CHECK (organization_id IS NOT NULL) NOT VALID
        SQL
      end
    end

    def validate_not_null_constraint
      # Validate the constraint (safe, minimal locking)
      say_with_time 'Validating NOT NULL constraint' do
        safety_assured do
          execute <<-SQL
            ALTER TABLE learning_categories
            VALIDATE CONSTRAINT learning_categories_organization_id_null
          SQL
        end
      end
    end

    def make_organization_required
      # Skip if column is already NOT NULL (idempotent migration)
      column_info = connection.columns(:learning_categories).find { |col| col.name == 'organization_id' }
      return if column_info && !column_info.null

      # Now safe to set NOT NULL because we have a validated constraint
      safety_assured { change_column_null :learning_categories, :organization_id, false }
    end

    def cleanup_constraint
      # Skip if constraint doesn't exist (idempotent migration)
      constraint_exists = safety_assured do
        execute(<<-SQL).to_a.any?
          SELECT 1 FROM pg_constraint
          WHERE conname = 'learning_categories_organization_id_null'
        SQL
      end
      return unless constraint_exists

      # Drop the redundant CHECK constraint (NOT NULL column constraint is sufficient)
      safety_assured do
        execute 'ALTER TABLE learning_categories DROP CONSTRAINT learning_categories_organization_id_null'
      end
    end

    def update_indexes
      check_for_duplicate_categories
      remove_old_name_index
      add_composite_organization_name_index
    end

    def check_for_duplicate_categories
      # safety_assured is needed because strong_migrations can't inspect execute statements
      duplicates_count = safety_assured do
        execute(<<-SQL).to_a.first['count'].to_i
          SELECT COUNT(*) as count FROM (
            SELECT organization_id, name, COUNT(*)
            FROM learning_categories
            WHERE deleted_at IS NULL
            GROUP BY organization_id, name
            HAVING COUNT(*) > 1
          ) duplicates
        SQL
      end

      return unless duplicates_count.positive?

      raise "Cannot add unique index: Found #{duplicates_count} duplicate organization_id/name combinations"
    end

    def remove_old_name_index
      return unless index_exists?(:learning_categories, :name, name: 'index_learning_categories_on_name')

      safety_assured { remove_index :learning_categories, name: 'index_learning_categories_on_name' }
    end

    def add_composite_organization_name_index
      return if index_exists?(:learning_categories, %i[organization_id name],
                              name: 'index_learning_categories_on_org_and_name')

      safety_assured do
        add_index :learning_categories, %i[organization_id name],
                  unique: true,
                  where: 'deleted_at IS NULL',
                  name: 'index_learning_categories_on_org_and_name',
                  algorithm: :concurrently
      end
    end

    def restore_old_index
      if index_exists?(:learning_categories, %i[organization_id name],
                       name: 'index_learning_categories_on_org_and_name')
        remove_index :learning_categories, name: 'index_learning_categories_on_org_and_name',
                                           algorithm: :concurrently
      end

      add_index :learning_categories, :name,
                unique: true,
                where: 'deleted_at IS NULL',
                name: 'index_learning_categories_on_name',
                algorithm: :concurrently
    end

    def remove_organization_reference
      # Remove foreign key first
      remove_foreign_key :learning_categories, :organizations if foreign_key_exists?(:learning_categories, :organizations)
      # Then remove column and its index
      remove_reference :learning_categories, :organization
    end
end
