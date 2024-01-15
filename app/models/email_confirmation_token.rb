
class EmailConfirmationToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :user_id, presence: true
  validates :expires_at, presence: true

  before_create :generate_unique_confirmation_token, :set_expiration_date

  def generate_unique_confirmation_token
    begin
      self.token = SecureRandom.hex(10) # or another token generation strategy
    end while EmailConfirmation.exists?(token: self.token)
  end

  private

  def set_expiration_date
    self.expires_at ||= 24.hours.from_now
  end
end
