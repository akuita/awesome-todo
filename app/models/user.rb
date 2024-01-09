class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :lockable,
         :validatable,
         :trackable, :recoverable, :lockable

  # validations

  PASSWORD_FORMAT = //
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, length: { in: 6..128 }, if: :password
  validates :password_confirmation, presence: true, if: :password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, length: { in: 0..255 }, if: :email?

  validates :encrypted_password, presence: true

  validates :sign_in_count, numericality: { only_integer: true }
  validates :failed_attempts, numericality: { only_integer: true }
  validates :unlock_token, uniqueness: true, allow_nil: true
  validates :reset_password_token, uniqueness: true, allow_nil: true
  validates :confirmation_token, uniqueness: true, allow_nil: true

  # end for validations

  # associations
  # Add your new associations here, if any.

  # end for associations

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
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

    # Add class methods here, if any.
  end

  # instance methods
  # Add instance methods here, if any.

  # end for instance methods
end
