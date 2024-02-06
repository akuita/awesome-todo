class Error < ApplicationRecord
  belongs_to :project

  validates :message, presence: true
  validates :timestamp, presence: true
  validates :project_id, presence: true

  # Add any custom logic here

end
