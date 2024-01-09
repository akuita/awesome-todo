class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable

  # Associations
  has_one :email_confirmation, foreign_key: 'user_id', dependent: :destroy

  # Validations
  PASSWORD_FORMAT = //
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, presence: true, confirmation: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  validates :email, presence: true, uniqueness: true, length: { in: 0..255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true

  validates :sign_in_count, numericality: { only_integer: true }
  validates :failed_attempts, numericality: { only_integer: true }
  validates :unlock_token, uniqueness: true, allow_nil: true
  validates :reset_password_token, uniqueness: true, allow_nil: true
  validates :confirmation_token, uniqueness: true, allow_nil: true

  # Callbacks
  # Include any necessary callbacks like before_save, after_create, etc.

  # Methods
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
  end

  # Scopes
  # Include any necessary scopes that are needed for this model
end
