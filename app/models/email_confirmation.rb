
class EmailConfirmation < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true
  validates :user_id, presence: true

  # Callbacks
  before_create :set_defaults

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
  end
end
