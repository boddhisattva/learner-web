# frozen_string_literal: true

class RemovePublicVisibilityFromLearnings < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_column :learnings, :public_visibility, :boolean
    end
  end

  def down
    safety_assured do
      add_column :learnings, :public_visibility, :boolean, null: false, default: false,
                                                           comment: 'Determines organizational visibility of the learning'
    end
  end
end
