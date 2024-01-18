class CreateTodoTags < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_tags do |t|
      t.references :todo, null: false, foreign_key: true, index: true
      t.references :tag, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
