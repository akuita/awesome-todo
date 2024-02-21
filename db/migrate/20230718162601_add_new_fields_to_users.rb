class AddNewFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :username, :string
    add_column :users, :password_hash, :string
    add_column :users, :is_active, :boolean, default: true

    # Ensure to add only new fields that are not already present in the schema
    # The fields listed below are already present in the schema and should not be added again
    # add_column :users, :sign_in_count, :integer, default: 0, null: false
    # add_column :users, :remember_created_at, :datetime
    # add_column :users, :current_sign_in_ip, :string
    # add_column :users, :locked_at, :datetime
    # add_column :users, :encrypted_password, :string, null: false, default: ''
    # add_column :users, :confirmed_at, :datetime
    # add_column :users, :failed_attempts, :integer, default: 0, null: false
    # add_column :users, :last_sign_in_ip, :string
    # add_column :users, :confirmation_token, :string
    # add_column :users, :unconfirmed_email, :string
    # add_column :users, :email, :string, null: false, default: ''
    # add_column :users, :reset_password_token, :string
    # add_column :users, :password_confirmation, :string
    # add_column :users, :last_sign_in_at, :datetime
    # add_column :users, :reset_password_sent_at, :datetime
  end
end
