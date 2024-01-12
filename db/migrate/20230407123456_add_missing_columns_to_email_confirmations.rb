# frozen_string_literal: true

class AddMissingColumnsToEmailConfirmations < ActiveRecord::Migration[6.1]
  def change
    change_table :email_confirmations do |t|
      # The current code already has :token, :confirmed, :expires_at, and :user references
      # Adding new columns :id, :created_at, :updated_at, :confirmation_token, :sent_at, and :confirmed_at
      # Since :created_at and :updated_at are already handled by t.timestamps, we do not need to add them again

      # Adding the :id column as a primary key
      t.primary_key :id

      # Adding the :confirmation_token column
      t.string :confirmation_token, null: true

      # Adding the :sent_at column
      t.datetime :sent_at, null: true

      # Adding the :confirmed_at column
      t.datetime :confirmed_at, null: true

      # The index for :confirmation_token is already added in the previous migration
      # The index for :token is already added in the previous migration
    end
  end
end
