# frozen_string_literal: true

class CreateEmailConfirmationsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :email_confirmations do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string   :token,      null: false
      t.boolean  :confirmed,  null: false, default: false
      t.datetime :expires_at, null: false
      t.references :user,     null: false, foreign_key: true
    end

    add_index :email_confirmations, :token, unique: true
  end
end
