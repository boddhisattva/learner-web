class RemoveLearningCategoryIdsFromLearnings < ActiveRecord::Migration[8.1]
  def change
    remove_index :learnings, :learning_category_ids, using: 'gin'

    safety_assured do
      remove_column :learnings, :learning_category_ids, :integer,
                    array: true,
                    default: [],
                    comment: 'Collection of different learning categories a Learning belongs to'
    end
  end
end
