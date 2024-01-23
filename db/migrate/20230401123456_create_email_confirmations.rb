class CreateEmailConfirmations < ActiveRecord::Migration[7.0]
  def change
    create_table :email_confirmations do |t|
      t.string :token
      t.boolean :confirmed, default: false
      t.datetime :expires_at
      t.references :user, foreign_key: true

      t.index :token, unique: true

      t.timestamps
    end
  end
end
