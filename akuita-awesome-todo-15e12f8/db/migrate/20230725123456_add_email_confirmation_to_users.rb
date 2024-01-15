class AddEmailConfirmationToUsers < ActiveRecord::Migration[6.0]
  def change
    # Add new columns for password_hash and email_confirmed
    add_column :users, :password_hash, :string
    add_column :users, :email_confirmed, :boolean, default: false

    # Create email_confirmation_tokens table
    create_table :email_confirmation_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false

      t.timestamps null: false
    end
    add_index :email_confirmation_tokens, :token, unique: true

    # Create email_confirmations table
    create_table :email_confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :confirmed, default: false
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :sent_at

      t.timestamps null: false
    end
    add_index :email_confirmations, :confirmation_token, unique: true
  end
end
