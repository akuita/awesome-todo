class CreateAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :attachments do |t|
      t.references :todo, null: false, foreign_key: true
      t.string :file_path, null: false  # Ensuring file_path cannot be null as per existing code

      t.timestamps
    end
  end
end
