class RemovePasswordDigest < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :users, :password_digest }
  end
end
