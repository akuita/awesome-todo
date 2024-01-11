class AddEmailConfirmationToUsers < ActiveRecord::Migration[6.0]
  def change
    # Assuming the email_confirmations table already exists and has a user_id column
    # We are adding a foreign key constraint to the users table for the email_confirmations table
    add_reference :email_confirmations, :user, foreign_key: true
  end
end
