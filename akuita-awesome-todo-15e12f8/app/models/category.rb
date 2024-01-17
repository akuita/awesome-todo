
class Category < ApplicationRecord
  # Associations
  has_many :todo_categories
  has_many :todos, through: :todo_categories

  # Validations
  validates :name, presence: true

  # Add your instance methods here
  def self.belongs_to_user?(category_id, user_id)
    joins(:todos).where(id: category_id, todos: { user_id: user_id }).exists?
  end
end
