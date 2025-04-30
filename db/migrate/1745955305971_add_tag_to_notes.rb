class AddTagToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :tag, :string
  end
end
