class AddEmailConfirmationsToUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :confirmation_token
      t.datetime :sent_at
      t.datetime :confirmed_at

      t.timestamps null: false
    end

    add_index :email_confirmations, :confirmation_token, unique: true
  end
end
