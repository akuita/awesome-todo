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

  validates :email, presence: true, uniqueness: true

  validates :email, length: { in: 0..255 }, if: :email?

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # end for validations
  validates_confirmation_of :password, if: -> { new_record? || password.present? }
  validates_presence_of :password, :password_confirmation, if: -> { new_record? || password.present? }

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
