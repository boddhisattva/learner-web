# frozen_string_literal: true

class MigrateLearningCategoryIdsToJoinTable < ActiveRecord::Migration[8.1]
  def up
    say_with_time 'Migrating learning_category_ids to categorizations' do
      counters = { migrated: 0, skipped: 0 }

      Learning.where.not(learning_category_ids: []).find_each(batch_size: 100) do |learning|
        migrate_learning_categories(learning, counters)
      end

      report_migration_results(counters)
    end
  end

  def down
    say_with_time 'Reverting categorizations to learning_category_ids' do
      Learning.find_each(batch_size: 100) do |learning|
        revert_learning_categories(learning)
      end
    end
  end

  private

    def migrate_learning_categories(learning, counters)
      learning.learning_category_ids.each do |category_id|
        next if skip_category?(learning, category_id, counters)

        create_categorization(learning, category_id)
        counters[:migrated] += 1
      end
    end

    def skip_category?(learning, category_id, counters)
      unless LearningCategory.exists?(category_id)
        say "  Skipping orphan category_id: #{category_id} for learning_id: #{learning.id}", :yellow
        counters[:skipped] += 1
        return true
      end

      if LearningCategorization.exists?(learning_id: learning.id, category_id: category_id)
        say "  Skipping duplicate categorization: learning_id=#{learning.id}, category_id=#{category_id}", :yellow
        counters[:skipped] += 1
        return true
      end

      false
    end

    def create_categorization(learning, category_id)
      # rubocop:disable Rails/SkipsModelValidations
      # Insert the join record (bypasses validations since organization_id doesn't exist yet)
      LearningCategorization.insert_all([{
                                          learning_id: learning.id,
                                          category_id: category_id,
                                          created_at: learning.created_at,
                                          updated_at: learning.updated_at
                                        }])
      # rubocop:enable Rails/SkipsModelValidations
    end

    def report_migration_results(counters)
      say "  Migrated #{counters[:migrated]} categorizations", :green
      return unless counters[:skipped].positive?

      say "  Skipped #{counters[:skipped]} invalid/duplicate entries", :yellow
    end

    def revert_learning_categories(learning)
      category_ids = LearningCategorization
                     .where(learning_id: learning.id)
                     .pluck(:category_id)

      # rubocop:disable Rails/SkipsModelValidations
      # update_column is necessary here for PostgreSQL array columns in data migrations
      learning.update_column(:learning_category_ids, category_ids)
      # rubocop:enable Rails/SkipsModelValidations
    end
end
