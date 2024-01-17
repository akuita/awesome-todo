class Attachment < ApplicationRecord
  belongs_to :todo

  has_one_attached :file

  validates :todo_id, presence: true
  validates :file, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'], size: { less_than: 10.megabytes }
end

