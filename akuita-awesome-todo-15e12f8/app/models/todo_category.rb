class TodoCategory < ApplicationRecord
  belongs_to :todo
  belongs_to :category

  validates :todo_id, presence: true
  validates :category_id, presence: true
  # Keep the uniqueness validation from the existing code
  validates :todo_id, uniqueness: { scope: :category_id, message: 'is already associated with this category' }

  # Include the custom validation method from the new code
  validate :category_belongs_to_user

  private

  # Include the custom validation method from the new code
  def category_belongs_to_user
    unless Category.belongs_to_user?(category_id, todo.user_id)
      errors.add(:category_id, 'must belong to the same user as the todo')
    end
  end
end
