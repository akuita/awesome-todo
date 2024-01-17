class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable
  require 'email_format_validator'

  # Associations
  has_many :email_confirmations, foreign_key: 'user_id', dependent: :destroy

  # Validations
  PASSWORD_FORMAT = //
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, if: -> { new_record? || password.present? }
  validates :password_confirmation, presence: true, if: -> { new_record? || password.present? }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, email_format: true
  validates :encrypted_password, presence: true
  validates :sign_in_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :failed_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :email, length: { in: 0..255 }, if: :email?

  # Callbacks
  after_create :generate_email_confirmation

  # Methods
  def generate_email_confirmation
    EmailConfirmation.generate_for_user(self.id)
  end

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  def confirm_email
    update(email_confirmed: true)
  end

  def confirm_email_with_token(email_confirmation_token)
    email_confirmation = EmailConfirmation.find_by(token: email_confirmation_token)
    if email_confirmation && email_confirmation.expires_at > Time.current
      update(
        email_confirmed: true,
        email_confirmation_token: nil,
        email_confirmation_sent_at: nil
      )
    else
      raise StandardError.new 'Token is invalid or expired'
    end
  end

  def generate_new_confirmation_token
    new_token = SecureRandom.urlsafe_base64
    self.email_confirmation_token = new_token
    self.email_confirmation_sent_at = Time.current
    save(validate: false)
  end

  # Scopes
  scope :unconfirmed_with_email, ->(email) do
    where(email: email, email_confirmed: false)
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

    def create_with_encrypted_password(email, password_hash)
      create(
        email: email,
        encrypted_password: Devise::Encryptor.digest(self, password_hash),
        email_confirmed: false, # Assuming this attribute exists in the database schema
        created_at: Time.current, updated_at: Time.current
      )
    end
  end
end
