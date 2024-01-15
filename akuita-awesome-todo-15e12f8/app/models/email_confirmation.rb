class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user

  # Generates a new confirmation token and updates the timestamps
  def regenerate_confirmation_token
    self.token = SecureRandom.hex(10) # Assuming SecureRandom is available in the project
    self.created_at = Time.current
    self.expires_at = 15.minutes.from_now
    save!
  end

  def confirm_email(token)
    email_confirmation = EmailConfirmation.find_by(token: token, 'expires_at > ?', Time.now.utc)
    if email_confirmation
      EmailConfirmation.transaction do
        email_confirmation.update!(confirmed: true)
        user = email_confirmation.user
        user.confirm_email
      end
    else
      raise StandardError.new 'Confirmation link is invalid or expired.'
    end
  rescue ActiveRecord::RecordInvalid => e
    raise StandardError.new e.message
  end
end
