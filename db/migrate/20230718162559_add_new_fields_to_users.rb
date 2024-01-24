class AddNewFieldsToUsers < ActiveRecord::Migration[6.0]
  def up
    change_table :users do |t|
      t.string :username, null: true
      t.string :name, null: true
      t.boolean :email_confirmed, default: false
      t.string :password_hash
    end

    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username

    change_table :users do |t|
      t.remove :username
      t.remove :name
      t.remove :email_confirmed
      t.remove :password_hash
    end
  end
end
