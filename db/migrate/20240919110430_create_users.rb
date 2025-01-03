# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :first_name, null: false, comment: 'User first name'
      t.string :last_name, null: false, comment: 'User last name'
      t.string :email, comment: 'User email'
      t.string :password_digest, comment: 'User password'

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
