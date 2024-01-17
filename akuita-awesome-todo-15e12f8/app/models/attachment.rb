
class Attachment < ApplicationRecord
  belongs_to :todo

  has_one_attached :file

  # Ensure the todo_id is present
  validates :todo_id, presence: true
  # Validate the presence of the file, its content type, and its size
  validates :file, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'], size: { less_than: 10.megabytes }
end
