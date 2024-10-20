class CreateLearningCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :learning_categories do |t|
      t.string :name, null: false, comment: 'Name of the learning category'
      t.text :description, comment: 'More information about the learning category'
      t.references :creator, null: false, foreign_key: { to_table: :users },
comment: 'User who created the learning category'
      t.references :last_modifier, null: false, foreign_key: { to_table: :users },
comment: 'User who last modified the learning category'
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :learning_categories, :name, unique: true
    add_index :learning_categories, :deleted_at
  end
end
