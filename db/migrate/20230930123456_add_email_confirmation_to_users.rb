class AddEmailConfirmationToUsers < ActiveRecord::Migration[6.0]
  def change
    # Assuming the email_confirmation_tokens table and model already exist
    # and we are just adding the reference in the users table.
    add_reference :users, :email_confirmation_token, foreign_key: true
  end
end
