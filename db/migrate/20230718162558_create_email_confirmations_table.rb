# This migration is responsible for creating the email_confirmations table
class CreateEmailConfirmationsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :email_confirmations do |t|
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.boolean :confirmed, default: false, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :email_confirmations, :token, unique: true
  end
end
