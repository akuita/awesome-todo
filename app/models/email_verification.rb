class EmailVerification < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'

  validates :token, presence: true
  validates :user_id, presence: true
  validates :expires_at, presence: true
  validates :is_used, inclusion: { in: [true, false] }

  before_create :generate_verification_token

  private

  def generate_verification_token
    begin
      self.token = SecureRandom.hex(10)
    end while self.class.exists?(token: token)
    self.expires_at = 24.hours.from_now
    self.is_used = false
  end

  # Add any other necessary validations here

  # You can also include callbacks, methods, or any other code related to the EmailVerification model

  # Remember to maintain the code style and structure as shown in the reference file
end
