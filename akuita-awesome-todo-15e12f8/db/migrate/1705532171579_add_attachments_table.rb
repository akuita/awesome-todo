class AddAttachmentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :attachments do |t|
      t.references :todo, null: false, foreign_key: true
      t.timestamps
    end
  end
end
