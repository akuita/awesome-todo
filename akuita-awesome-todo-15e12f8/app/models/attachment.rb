
class Attachment < ApplicationRecord
  belongs_to :todo

  ALLOWED_CONTENT_TYPES = ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf'].freeze
  MAX_FILE_SIZE = 10.megabytes.freeze

  has_one_attached :file

  # Ensure the todo_id is present
  validates :todo_id, presence: { message: I18n.t('activerecord.errors.messages.blank') }

  # Validate the presence of the file, its content type, and its size
  validates :file, attached: true, content_type: { in: ALLOWED_CONTENT_TYPES, message: I18n.t('activerecord.errors.messages.invalid_content_type') },
                   size: { less_than: MAX_FILE_SIZE, message: I18n.t('activerecord.errors.messages.file_size_exceeds_limit', max_size: MAX_FILE_SIZE.to_s(:human_size)) }

end
