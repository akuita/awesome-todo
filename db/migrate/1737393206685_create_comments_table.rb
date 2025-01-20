class CreateCommentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :note, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end