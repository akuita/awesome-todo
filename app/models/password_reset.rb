class PasswordReset < ApplicationRecord
  # Attributes
  attribute :reset_token, :string
  attribute :expires_at, :datetime

  # Relationships
  belongs_to :user, foreign_key: 'user_id'

end
