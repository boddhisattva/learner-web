# frozen_string_literal: true

class CreateLearningCategorizations < ActiveRecord::Migration[8.1]
  def change
    create_table :learning_categorizations do |t|
      t.references :learning, null: false, foreign_key: true, index: true
      t.references :category, null: false, foreign_key: { to_table: :learning_categories }, index: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :learning_categorizations,
              %i[learning_id category_id],
              unique: true,
              where: 'deleted_at IS NULL',
              name: 'index_learning_categorizations_uniqueness'

    add_index :learning_categorizations, :deleted_at
  end
end
