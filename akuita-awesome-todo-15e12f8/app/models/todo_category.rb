class TodoCategory < ApplicationRecord
  belongs_to :todo
  belongs_to :category

  validates :todo_id, presence: true
  validates :category_id, presence: true
  validates :todo_id, uniqueness: { scope: :category_id, message: 'is already associated with this category' }

  validate :category_belongs_to_user

  private

  def category_belongs_to_user
    unless Category.belongs_to_user?(category_id, todo.user_id)
      errors.add(:category_id, 'must belong to the same user as the todo')
    end
  end
end
