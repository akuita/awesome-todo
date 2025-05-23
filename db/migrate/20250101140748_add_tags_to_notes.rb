class AddTagsToNotes < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :tags, :string
  end
end
