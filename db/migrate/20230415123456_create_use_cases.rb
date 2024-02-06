class CreateUseCases < ActiveRecord::Migration[6.0]
  def change
    create_table :use_cases do |t|
      t.string :title
      t.text :description
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
