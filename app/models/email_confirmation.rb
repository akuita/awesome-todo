class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :token, presence: true
  validates :expires_at, presence: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :user_id, presence: true

  # methods
  def expired?
    Time.current > expires_at
  end

  def confirm!
    update(confirmed: true) unless confirmed?
  end

  def confirmed?
    confirmed
  end

  def generate_unique_confirmation_token
    begin
      self.token = SecureRandom.urlsafe_base64
    end while self.class.exists?(token: token)
    self.expires_at = 15.minutes.from_now
    save
  end

  def create_confirmation_record(user_id)
    self.user_id = user_id
    generate_unique_confirmation_token # Replaced the call to generate_token with the new method
    self.confirmed = false
    self.created_at = Time.current
    save
  end
end
