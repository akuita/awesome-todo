
class Category < ApplicationRecord
  has_many :todo_categories
  has_many :todos, through: :todo_categories
end
