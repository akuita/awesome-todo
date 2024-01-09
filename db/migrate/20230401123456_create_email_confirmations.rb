class CreateEmailConfirmations < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmations do |t|
      t.string :token
      t.boolean :confirmed, default: false
      t.datetime :expires_at
      t.references :user, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :email_confirmations, :token, unique: true
  end
end