class AddNewColumnsToUsersTable < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :password_hash, :string
    add_column :users, :email_confirmed, :boolean, default: false
    add_column :users, :email_confirmation_token, :string
    add_column :users, :email_confirmation_sent_at, :datetime

    add_index :users, :email_confirmation_token, unique: true
  end
end
