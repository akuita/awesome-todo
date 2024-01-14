class CreateEmailConfirmationTokensTable < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmation_tokens do |t|
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :email_confirmation_tokens, :token, unique: true
  end
end
