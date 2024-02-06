class ImportSource < ApplicationRecord
  # Validations
  validates :name, presence: true

  # Custom logic (if any)

  # Associations (if any)
  # Example: belongs_to :user
  # Example: has_many :imported_items, dependent: :destroy

end
