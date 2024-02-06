class FigmaImport < ApplicationRecord
  # Associations
  belongs_to :project

  # Validations
  validates :figma_file_id, presence: true
  validates :imported_at, presence: true
  validates :project_id, presence: true

  # Custom logic (if any)
end
