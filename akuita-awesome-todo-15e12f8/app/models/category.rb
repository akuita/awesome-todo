
class Category < ApplicationRecord
  # Associations
  has_many :todo_categories
  has_many :todos, through: :todo_categories

  # Validations
  validates :name, presence: true

  # Add your instance methods here
  def belongs_to_user?(category_id, user_id)
    Category.where(id: category_id).joins(:todos).where(todos: { user_id: user_id }).exists?
  end

  # Other instance methods

  def associated_with_user?(user_id)
    todo_categories.joins(:todo).where(todos: { user_id: user_id }).exists?
  end

  def self.belongs_to_user?(category_id, user_id)
    joins(:todos).where(id: category_id, todos: { user_id: user_id }).exists?
  end
end
