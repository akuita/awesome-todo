class EmailConfirmationRequest < ApplicationRecord
  # Associations
  belongs_to :user, foreign_key: 'user_id'

  # Validations
  validates :requested_at, presence: true
  validates :user_id, presence: true

  # Callbacks
  # Add any callbacks like before_save, after_commit, etc.

  # Methods
  # Add any instance or class methods that are necessary

  # Scopes
  # Add any scopes if needed
end
