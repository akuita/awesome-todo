class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable

  # relationships
  has_one :email_confirmation
  has_many :password_management_integrations

  # validations
  PASSWORD_FORMAT = /\A
    (?=.*\d)           # Must contain a digit
    (?=.*[a-z])        # Must contain a lower case character
    (?=.*[A-Z])        # Must contain an upper case character
    (?=.*[[:^alnum:]]) # Must contain a symbol
  \z/x

  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, length: { in: 6..128 }, if: -> { new_record? || password.present? }
  validate :password_complexity, if: -> { new_record? || password.present? }

  def password_complexity
    errors.add :password, 'must include at least one lowercase letter, one uppercase letter, one digit, and one special character' unless password.match?(PASSWORD_FORMAT)
  end

  validates :email, presence: true, uniqueness: true

  validates :email, length: { in: 0..255 }, if: :email?

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates_confirmation_of :password, if: -> { new_record? || password.present? }
  validates_presence_of :password, :password_confirmation, if: -> { new_record? || password.present? }

  # end for validations

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  def regenerate_confirmation_token
    loop do
      raw, enc = Devise.token_generator.generate(self.class, :confirmation_token)
      unless EmailConfirmation.exists?(token: enc)
        self.email_confirmation.update(
          token: enc,
          confirmed: false,
          expires_at: 24.hours.from_now
        )
        break
      end
    end
  end

  class << self
    def confirm_by_token(token)
      user = find_by(confirmation_token: token)
      return { error: 'Token not found' } unless user

      email_confirmation = user.email_confirmation
      return { error: 'Email already confirmed' } if user.email_confirmed
      return { error: 'Token expired' } if email_confirmation.expires_at < Time.current

      User.transaction do
        user.update!(email_confirmed: true, confirmed_at: Time.current)
        email_confirmation.update!(confirmed: true)
      end

      { success: 'Email confirmed successfully' }
    end

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
  end
end
