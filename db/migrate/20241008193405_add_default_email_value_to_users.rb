class AddDefaultEmailValueToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users, :email, from: nil, to: ''
  end
end
