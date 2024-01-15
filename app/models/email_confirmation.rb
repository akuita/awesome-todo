class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :token, presence: true, uniqueness: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :expires_at, presence: true
  validates :user_id, presence: true

  # callbacks
  # Add any callbacks like before_create, after_commit, etc here

  # scopes
  # Define any custom scopes here

  # methods
  # Define any custom instance or class methods here

  # Check if the confirmation token is expired
  def generate_new_confirmation_token
    self.token = generate_unique_token
    self.expires_at = 24.hours.from_now
    self.created_at = Time.current
    save
  end

  private

  def generate_unique_token
    SecureRandom.hex(10)
  end

  def expired?
    Time.current > expires_at
  end

  # Confirm the email
  def confirm_email
    unless confirmed?
      self.confirmed = true
      save
    end
  end

  # Check if the email is already confirmed
  def confirmed?
    confirmed
  end
end
