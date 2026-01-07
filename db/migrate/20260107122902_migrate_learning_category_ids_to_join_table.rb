# frozen_string_literal: true

class MigrateLearningCategoryIdsToJoinTable < ActiveRecord::Migration[8.1]
  def up
    say_with_time 'Migrating learning_category_ids to categorizations' do
      migrated_count = 0
      skipped_count = 0

      Learning.where.not(learning_category_ids: []).find_each(batch_size: 100) do |learning|
        learning.learning_category_ids.each do |category_id|
          unless LearningCategory.exists?(category_id)
            say "  Skipping orphan category_id: #{category_id} for learning_id: #{learning.id}", :yellow
            skipped_count += 1
            next
          end

          if LearningCategorization.exists?(learning_id: learning.id, category_id: category_id)
            say "  Skipping duplicate categorization: learning_id=#{learning.id}, category_id=#{category_id}", :yellow
            skipped_count += 1
            next
          end

          # Insert the join record (bypasses validations since organization_id doesn't exist yet)
          LearningCategorization.insert_all([{
                                              learning_id: learning.id,
                                              category_id: category_id,
                                              created_at: learning.created_at,
                                              updated_at: learning.updated_at
                                            }])
          migrated_count += 1
        end
      end

      say "  Migrated #{migrated_count} categorizations", :green
      say "  Skipped #{skipped_count} invalid/duplicate entries", :yellow if skipped_count > 0
    end
  end

  def down
    say_with_time 'Reverting categorizations to learning_category_ids' do
      Learning.find_each(batch_size: 100) do |learning|
        category_ids = LearningCategorization
                       .where(learning_id: learning.id)
                       .pluck(:category_id)

        learning.update_column(:learning_category_ids, category_ids)
      end
    end
  end
end
