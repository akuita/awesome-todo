class CreateTodoCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_categories do |t|
      t.references :todo, null: false, foreign_key: true, index: true
      t.references :category, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
