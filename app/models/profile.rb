class Profile < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'

  # validations
  validates :user_id, presence: true
  # Add other necessary validations as needed

  # Add any custom methods, scopes, etc below this line

  # Remember to include timestamps
  # created_at and updated_at are automatically managed by Rails if the migration includes t.timestamps
end

