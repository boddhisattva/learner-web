class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name, comment: 'User name'
      t.string :email, comment: 'User email'
      t.string :password_digest, comment: 'User password'

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
