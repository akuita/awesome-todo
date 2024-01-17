# frozen_string_literal: true

class CreateEmailConfirmationRequestsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :email_confirmation_requests do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.datetime :requested_at, null: false
      t.references :user, null: false, foreign_key: true
    end
  end
end
