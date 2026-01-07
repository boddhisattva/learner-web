# frozen_string_literal: true

class AddLearningsCountToMemberships < ActiveRecord::Migration[7.2]
  def change
    add_column :memberships, :learnings_count, :integer, default: 0, null: false,
                                                         comment: 'Counter cache for learnings count per user per organization'
  end
end
