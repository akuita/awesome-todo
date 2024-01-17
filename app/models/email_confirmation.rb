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

  # This method combines the logic of both generate_token and generate_unique_confirmation_token
  def generate_token
    loop do
      # Use SecureRandom.urlsafe_base64 for better entropy
      self.token = SecureRandom.urlsafe_base64
      # Set expires_at to 24 hours from now, or modify as needed
      self.expires_at = 24.hours.from_now
      break unless EmailConfirmation.exists?(token: token)
    end
    save
  end

  def log_request(user_id, timestamp)
    EmailConfirmationRequest.create!(
      user_id: user_id,
      requested_at: timestamp
    )
  end


  # This method is kept from the existing code to handle creating a confirmation record
  def create_confirmation_record(user_id)
    self.user_id = user_id
    generate_token # Use the combined generate_token method
    self.confirmed = false
    self.created_at = Time.current
    save
  end
end
