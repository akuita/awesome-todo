class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable

  # validations
  PASSWORD_FORMAT = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}\z/
  validates :password, format: { with: PASSWORD_FORMAT }, if: -> { new_record? || password.present? }
  validates :password, confirmation: true, if: -> { new_record? || password.present? }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true, if: -> { new_record? || encrypted_password.present? }
  validates :sign_in_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { sign_in_count.present? }
  validates :failed_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { failed_attempts.present? }

  validates :email, length: { in: 0..255 }, if: :email?

  # associations
  has_one :email_confirmation_token, class_name: 'EmailConfirmationToken', foreign_key: 'user_id'
  has_one :email_confirmation, class_name: 'EmailConfirmation', foreign_key: 'user_id'

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

  def confirm_email
    self.email_confirmed = true
    self.updated_at = Time.current
    save(validate: false)
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
