class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :confirmable,
         :trackable, :recoverable, :lockable

  # validations
  # ... (Assuming there are validations here, but they are not shown in the patch or the original code)

  # associations
  has_many :email_confirmations, foreign_key: :user_id, dependent: :destroy

  # Custom logic related to email confirmations
  def email_confirmed?
    email_confirmations.where(confirmed: true).exists?
  end

  # end for validations

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
  end

  # ... (Assuming there might be more methods or logic here, but they are not shown in the patch or the original code)

  def generate_confirmation_token
    email_confirmation = email_confirmations.find_or_initialize_by(confirmed: false)
    if email_confirmation.new_record? || email_confirmation.updated_at < 2.minutes.ago
      raw, enc = Devise.token_generator.generate(EmailConfirmation, :token)
      email_confirmation.token = enc
      email_confirmation.expires_at = Time.now.utc + Devise.confirm_within
      email_confirmation.save!
      raw # Return the raw token to be sent via email
    else
      # If the token was recently generated, return the existing token
      email_confirmation.token
    end
  end

  def confirm_email
    return false if confirmed_at.present?

    self.confirmed_at = Time.current
    save
  end
  
  # ... (Assuming there might be more methods or logic here, but they are not shown in the patch or the original code)
end
