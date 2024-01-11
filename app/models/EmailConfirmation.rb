class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user, foreign_key: 'user_id'

  # validations
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :user_id, presence: true

  # callbacks
  before_create :generate_token, :set_expiration

  private

  def generate_token
    self.token = SecureRandom.hex(10) # or another token generation strategy
  end

  def set_expiration
    self.expires_at ||= 24.hours.from_now
  end
end
