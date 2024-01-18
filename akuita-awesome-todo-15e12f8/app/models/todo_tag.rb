class TodoTag < ApplicationRecord
  belongs_to :todo
  belongs_to :tag

  validates :todo_id, presence: true, uniqueness: { scope: :tag_id, message: 'is already associated with this tag' }
  validates :tag_id, presence: true, uniqueness: { scope: :todo_id, message: 'is already associated with this todo' }

  # Custom validation methods if needed

  # Additional methods if needed
end
