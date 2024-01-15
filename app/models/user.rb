
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable

  # validations
  PASSWORD_FORMAT = //
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, confirmation: true, if: -> { new_record? || password.present? }

  # Update the email validation for uniqueness with case insensitive
  # The length validation for email is removed as it's redundant with the new email validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true, if: -> { new_record? || encrypted_password.present? }
  validates :sign_in_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { sign_in_count.present? }
  validates :failed_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { failed_attempts.present? }

  # associations
  has_one :email_confirmation_token, class_name: 'EmailConfirmationToken', foreign_key: 'user_id'

  # callbacks
  # Add any callbacks like before_save, after_commit, etc here

  # scopes
  # Define any custom scopes here

  # methods
  # Define any custom instance or class methods here

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  def confirm_email(confirmation_token)
    token_record = email_confirmation_token
    return false unless token_record && token_record.token == confirmation_token && confirmation_sent_at >= 2.days.ago

    self.email_confirmed = true
    token_record.destroy
    save
  end

  def regenerate_confirmation_token
    token_record = self.email_confirmation_token || self.build_email_confirmation_token
    raw, enc = Devise.token_generator.generate(self.class, :confirmation_token)
    token_record.token = enc
    token_record.expires_at = 2.days.from_now
    token_record.save!
    self.confirmation_sent_at = Time.now.utc
    self.confirmation_token = enc
    save(validate: false)
    raw
  end

  class << self
    def authenticate?(email, password)
      user = User.find_for_authentication(email: email)
      return false if user.blank?

      if user&.valid_for_authentication? { user.valid_password?(password) }
        user.reset_failed_attempts!
        return user
      end

      # We will show the error message in TokensController
      return user if user&.access_locked?

      false
    end

    # Define any custom class methods here
  end
end
