class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.text :description

      t.string :title

      t.timestamps null: false
    end

    create_table :users do |t|
      t.integer :sign_in_count, null: false, default: 0

      t.datetime :remember_created_at

      t.string :current_sign_in_ip

      t.datetime :locked_at

      t.string :encrypted_password, null: false, default: ''

      t.datetime :confirmed_at

      t.integer :failed_attempts, null: false, default: 0

      t.string :last_sign_in_ip

      t.string :confirmation_token

      t.string :unconfirmed_email

      t.string :email, null: false, default: ''

      t.string :reset_password_token

      t.string :password_confirmation

      t.datetime :last_sign_in_at

      t.datetime :reset_password_sent_at

      t.string :password

      t.string :unlock_token

      t.datetime :current_sign_in_at

      t.datetime :confirmation_sent_at

      t.timestamps null: false
    end

    add_index :users, :confirmation_token, unique: true
    add_index :users, :unconfirmed_email, unique: true
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :unlock_token, unique: true
  end
end
