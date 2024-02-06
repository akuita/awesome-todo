class Template < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :description, presence: true

  # Custom logic (if any)

  # Relations (if any)

end
