class Category < ApplicationRecord
  # existing associations and validations
  has_many :notes, dependent: :nullify
  has_many :todo_categories
  has_many :todos, through: :todo_categories
end
