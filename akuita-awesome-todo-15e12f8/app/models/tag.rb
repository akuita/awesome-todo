class Tag < ApplicationRecord
  # Associations
  has_many :todo_tags, dependent: :destroy
  has_many :todos, through: :todo_tags

  # Validations
  validates :name, presence: true
end
