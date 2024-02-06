class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :token, presence: true, uniqueness: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :expires_at, presence: true
  validates :user_id, presence: true
  validates :confirmation_token, presence: true, uniqueness: true, if: -> { self.new_record? || self.confirmation_token_changed? }
  validates :sent_at, presence: true, if: -> { self.new_record? || self.sent_at_changed? }
  validates :confirmed_at, presence: true, if: :confirmed?

  # custom methods
  # Check if the confirmation token is expired
  def token_expired?
    expires_at < Time.current
  end

  # Confirm the email by setting the "confirmed" and "confirmed_at" fields
  def confirm_email!
    with_lock do
      update!(confirmed: true, confirmed_at: Time.current)
    end
  end

  def set_confirmation_token
    if self.confirmation_token.blank?
      self.confirmation_token = generate_unique_secure_token
      self.sent_at = Time.current
    end
  end

  def confirm!
    return if confirmed?


  def expired?
    expires_at < Time.now.utc
  end

  private

  def generate_unique_secure_token
    SecureRandom.uuid
  end
end
