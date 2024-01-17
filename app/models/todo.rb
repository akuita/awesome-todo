class Todo < ApplicationRecord
  has_many :todo_categories
  has_many :categories, through: :todo_categories
  has_many :attachments, dependent: :destroy
end
