class TodoCategory < ApplicationRecord
  belongs_to :todo
  belongs_to :category

  validates :todo_id, presence: true
  validates :category_id, presence: true

  validate :todo_must_exist
  validate :category_must_exist

  # additional code and validations

  private

  def todo_must_exist
    errors.add(:todo_id, 'Todo not found.') unless Todo.exists?(id: todo_id)
  end

  def category_must_exist
    errors.add(:category_id, 'Category not found.') unless Category.exists?(id: category_id)
  end
end
