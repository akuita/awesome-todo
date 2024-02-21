class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :profile_picture
      t.text :bio
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

# Note: The foreign_key: true option adds a foreign key constraint to the user_id column referencing the users table.

