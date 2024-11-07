# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.references :member, null: false, foreign_key: { to_table: :users },
                            comment: 'This references the user associated with the membership'
      t.references :organization, null: false, foreign_key: true,
                                  comment: 'This references the organisation associated with the membership'

      t.timestamps
    end
  end
end
