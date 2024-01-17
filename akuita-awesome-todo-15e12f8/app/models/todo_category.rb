class TodoCategory < ApplicationRecord
  belongs_to :todo
  belongs_to :category

  validates :todo_id, presence: true
  validates :category_id, presence: true
end

# Note: The actual line numbers will be determined by the existing content of the file.
