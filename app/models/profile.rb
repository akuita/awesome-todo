
class Profile < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'

  # validations
  validates :user_id, presence: true
  validates :profile_picture, content_type: { in: ['image/png', 'image/jpg', 'image/jpeg'], message: I18n.t('activerecord.errors.messages.file_content_type_invalid') }, allow_blank: true
  validates :bio, length: { maximum: 500, message: I18n.t('activerecord.errors.messages.too_long', count: 500) }

  # Add any custom methods, scopes, etc below this line

  # Remember to include timestamps
  # created_at and updated_at are automatically managed by Rails if the migration includes t.timestamps
end
