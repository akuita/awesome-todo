
class EmailConfirmation < ApplicationRecord
  belongs_to :user

  # Generates a new confirmation token and updates the timestamps
  def regenerate_confirmation_token
    self.token = SecureRandom.hex(10) # Assuming SecureRandom is available in the project
    self.created_at = Time.current
    self.expires_at = 15.minutes.from_now
    save!
  end

end
