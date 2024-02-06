# frozen_string_literal: true

class CreateEmailConfirmations < ActiveRecord::Migration[6.1]
  def change
    create_table :email_confirmations do |t|
      t.string :token, null: false
      t.boolean :confirmed, default: false, null: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :email_confirmations, :token, unique: true
  end
end