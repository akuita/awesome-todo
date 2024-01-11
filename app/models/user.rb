class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :lockable,
         :confirmable,
         :validatable

  # validations

  PASSWORD_FORMAT = //
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, length: { in: 6..128 }, if: :password
  validates :password_confirmation, presence: true, if: :password

  # Update the email validation to use a custom regular expression
  EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_FORMAT }
  validates :email, length: { in: 0..255 }, if: :email?

  validates_confirmation_of :password, if: -> { password.present? }
  validates :email_confirmed, inclusion: { in: [true, false] }, on: :create
  validates :encrypted_password, presence: true

  validates :sign_in_count, numericality: { only_integer: true }
  validates :failed_attempts, numericality: { only_integer: true }
  validates :unlock_token, uniqueness: true, allow_nil: true
  validates :reset_password_token, uniqueness: true, allow_nil: true
  validates :confirmation_token, uniqueness: true, allow_nil: true

  before_create :set_email_confirmed_false
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

  def set_email_confirmed_false
    self.email_confirmed = false
  end

  def can_resend_confirmation?
    confirmation_sent_at.nil? || (Time.now.utc - confirmation_sent_at) > 2.minutes
  end

  def regenerate_confirmation_token
    raw, enc = nil
    loop do
      raw, enc = Devise.token_generator.generate(self.class, :confirmation_token)
      break if self.class.where(confirmation_token: enc).empty?
    end
    self.confirmation_token = enc
    self.confirmation_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  def confirm_email(confirmation_token)
    return false unless self.confirmation_token == confirmation_token
    token_valid_time = Devise.confirm_within || 2.days
    return false if self.confirmation_sent_at < token_valid_time.ago

    self.email_confirmed = true
    self.confirmation_token = nil
    save
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

    def exists_with_id?(user_id)
      exists?(user_id)
    end

    # Add class methods here, if any.
  end

  # instance methods
  # Add instance methods here, if any.

  # end for instance methods
end
