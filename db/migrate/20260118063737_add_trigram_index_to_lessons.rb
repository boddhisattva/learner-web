# frozen_string_literal: true

class AddTrigramIndexToLessons < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        CREATE INDEX CONCURRENTLY index_learnings_on_lesson_trgm
        ON learnings USING gin (lower(lesson) gin_trgm_ops);
      SQL
    end
  end

  def down
    remove_index :learnings, name: 'index_learnings_on_lesson_trgm', algorithm: :concurrently
  end
end
