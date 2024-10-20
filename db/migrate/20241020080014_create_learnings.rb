class CreateLearnings < ActiveRecord::Migration[7.2]
  def change
    create_table :learnings do |t|
      t.string :lesson, null: false, comment: 'Learning lesson learnt'
      t.text :description, comment: 'Learning lesson in more detail'
      t.references :creator, null: false, foreign_key: { to_table: :users }, comment: 'User who created the learning'
      t.datetime :deleted_at
      t.boolean :public, null: false, default: false, comment: 'Determines organizational visibility of the learning'
      t.integer :learning_categories, array: true, default: [],
comment: 'Collection of different learning categories a Learning belongs to'
      t.references :last_modifier, null: false, foreign_key: { to_table: :users },
comment: 'User who last modified the learning'
      t.references :organization, null: false, foreign_key: true,
comment: 'The organization to which the learning belongs'

      t.timestamps
    end
    add_index :learnings, :learning_categories, using: 'gin'
    add_index :learnings, :lesson
    add_index :learnings, :deleted_at
  end
end
