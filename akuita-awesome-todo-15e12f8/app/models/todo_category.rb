class TodoCategory < ApplicationRecord
  belongs_to :todo
  belongs_to :category

  validates :todo_id, presence: true
  validates :category_id, presence: true
  validates :todo_id, uniqueness: { scope: :category_id, message: 'is already associated with this category' }
end

# Note: The actual line numbers will be determined by the existing content of the file.
