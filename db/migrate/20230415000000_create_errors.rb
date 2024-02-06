class CreateErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :errors do |t|
      t.string :message
      t.datetime :timestamp
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
