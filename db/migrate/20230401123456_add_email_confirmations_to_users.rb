class AddEmailConfirmationsToUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email, null: false
      t.string :confirmation_token, null: false
      t.datetime :sent_at
      t.datetime :confirmed_at

      t.timestamps null: false
    end
  end
end
