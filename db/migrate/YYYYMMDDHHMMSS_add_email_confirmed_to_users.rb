class AddEmailConfirmedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_confirmed, :boolean, default: false
    add_column :users, :password_hash, :string

    # If there are other columns that need to be added or modified, they should be included here

    # Example: rename_column :users, :old_column_name, :new_column_name
  end
end
