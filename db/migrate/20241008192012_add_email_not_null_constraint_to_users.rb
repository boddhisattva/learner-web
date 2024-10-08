class AddEmailNotNullConstraintToUsers < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_check_constraint :users, "email IS NOT NULL", name: "users_email_null", validate: false
  end
end
