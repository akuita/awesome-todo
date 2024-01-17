
class Attachment < ApplicationRecord
  belongs_to :todo

  has_one_attached :file

  # Ensure the todo_id is present
  validates :todo_id, presence: { message: I18n.t('activerecord.errors.messages.blank') }

  # Validate the presence of the file, its content type, and its size
  validates :file, attached: true, content_type: { in: ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'], message: I18n.t('activerecord.errors.messages.invalid_content_type') }, size: { less_than: 10.megabytes, message: I18n.t('activerecord.errors.messages.file_size_exceeded', max_size: '10 MB') }

end
