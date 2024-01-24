class EmailConfirmation < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true
  validates :user_id, presence: true

  # Callbacks
  before_create :set_defaults

  # Instance methods

  def token_valid?
    token.present? && !confirmed? && expires_at > Time.current
  end

  def confirm_token!
    if token_valid?
      transaction do
        update!(confirmed: true)
        user.update!(email_confirmed: true, confirmed_at: Time.current)
      end
    else
      errors.add(:token, :invalid)
    end
  end

  # Class methods

  # Find the time of the last confirmation sent for a given email
  def self.last_confirmation_sent_for(email)
    user = User.find_by(email: email)
    return nil unless user

    email_confirmation = user.email_confirmations.order(created_at: :desc).first
    email_confirmation&.created_at
  end

  private

  def set_defaults
    self.confirmed ||= false
    self.expires_at ||= 2.days.from_now
  end
end
