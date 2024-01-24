class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :confirmable, :omniauthable,
         :trackable, :recoverable, :lockable

  # validations

  PASSWORD_FORMAT = //
  validates :password, length: { in: Devise.password_length }, if: -> { new_record? || password.present? }
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, confirmation: true, if: -> { new_record? || password.present? }

  validates :email, presence: true, uniqueness: { message: "This email address has already been used." }
  validates :email, length: { in: 0..255 }, if: :email?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Please enter a valid email address." }

  # end for validations

  # relationships
  has_one :email_confirmation_token, dependent: :destroy
  has_one :email_confirmation, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :todos, dependent: :destroy
  # end for relationships

  # Class method to find a user by confirmation token
  def self.find_by_confirmation_token(token)
    email_confirmation = EmailConfirmation.find_by(token: token, confirmed: false)
    if email_confirmation && email_confirmation.expires_at > Time.now.utc
      email_confirmation.user
    else
      nil
    end
  end

  # Instance method to confirm user's email
  def confirm_email
    self.email_confirmed = true
    self.email_confirmation&.destroy
    self.touch
  end
  # end for instance methods

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

    def email_exists?(email)
      where(email: email).exists?
    end
  end

  # instance methods
end
