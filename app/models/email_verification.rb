class EmailVerification < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'

  validates :token, presence: true
  validates :user_id, presence: true
  validates :expires_at, presence: true
  validates :is_used, inclusion: { in: [true, false] }

  # Add any other necessary validations here

  # You can also include callbacks, methods, or any other code related to the EmailVerification model

  # Remember to maintain the code style and structure as shown in the reference file
end
