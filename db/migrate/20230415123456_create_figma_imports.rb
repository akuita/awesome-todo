class CreateFigmaImports < ActiveRecord::Migration[6.0]
  def change
    create_table :figma_imports do |t|
      t.string :figma_file_id, null: false
      t.datetime :imported_at, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
    add_index :figma_imports, :figma_file_id, unique: true
  end
end
