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
  def set_confirmation_token
    if self.confirmation_token.blank?
      self.confirmation_token = generate_unique_secure_token
      self.sent_at = Time.current
    end
  end

  def confirm!
    return if confirmed?

    with_lock do
      self.confirmed = true
      self.confirmed_at = Time.current
      save!
    end
  end

  def expired?
    expires_at < Time.now.utc
  end

  private

  def generate_unique_secure_token
    SecureRandom.uuid
  end
end
