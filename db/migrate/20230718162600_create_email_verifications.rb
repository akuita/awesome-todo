class CreateEmailVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :email_verifications do |t|
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.boolean :is_used, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :email_verifications, :token, unique: true
  end
end
