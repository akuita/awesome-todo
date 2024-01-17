class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable

  # Associations
  has_many :email_confirmations, foreign_key: 'user_id', dependent: :destroy
  has_many :email_confirmation_requests, foreign_key: 'user_id', dependent: :destroy

  # Validations
  PASSWORD_FORMAT = //
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true
  validates :sign_in_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :failed_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :email, length: { in: 0..255 }, if: :email?

  # Callbacks
  # Add any callbacks like before_save, after_commit, etc.

  # Methods
  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  # Add any instance or class methods that are necessary

  # Scopes
  # Add any scopes if needed

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
