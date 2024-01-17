class AddEmailConfirmationsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, unique: true
      t.datetime :expires_at
      t.boolean :confirmed, default: false
      t.datetime :requested_at

      t.timestamps null: false
    end

    add_index :email_confirmations, :token, unique: true
    add_index :email_confirmations, :user_id
  end
end
