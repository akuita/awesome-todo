class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable, :confirmable

  # validations
  PASSWORD_FORMAT = /\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }
  validates :password, length: { minimum: 8 }, if: :password
  validates :password_confirmation, presence: true, if: :password
  validates :email, presence: true, uniqueness: true
  validates :email, length: { in: 0..255 }, if: :email?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :encrypted_password, presence: true
  validates :sign_in_count, numericality: { only_integer: true }
  validates :failed_attempts, numericality: { only_integer: true }
  validates :unlock_token, uniqueness: true, allow_nil: true
  validates :reset_password_token, uniqueness: true, allow_nil: true
  validates :confirmation_token, uniqueness: true, allow_nil: true

  # associations
  has_many :email_confirmations, foreign_key: 'user_id', dependent: :destroy

  # callbacks

  # scopes

  # class methods
  class << self
    def email_registered?(email)
      exists?(email: email)
    end

    def email_available?(email)
      !exists?(email: email)
    end

    def generate_unique_confirmation_token
      raw, enc = Devise.token_generator.generate(self, :confirmation_token)
      { raw: raw, enc: enc }
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

    def find_by_email_and_unconfirmed(email)
      user = find_by(email: email, email_confirmed: false)
      unless user
        raise ActiveRecord::RecordNotFound, "No unconfirmed user found with email: #{email}"
      end
      user
    end
  end

  # instance methods
  # Override Devise's password= method to ensure password confirmation is handled
  def password=(new_password)
    super(new_password)
    self.password_confirmation = new_password
  end

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  def generate_confirmation_token
    last_confirmation = email_confirmations.order(created_at: :desc).first
    if last_confirmation.nil? || last_confirmation.created_at < 2.minutes.ago
      token_pair = self.class.generate_unique_confirmation_token
      email_confirmations.create(token: token_pair[:enc], expires_at: 15.minutes.from_now)
      send_confirmation_email(token_pair[:raw])
    end
  end

  # Methods for password management tool integration
  def password_complexity_compatible?(password_management_tool)
    complexity_requirements = {
      min_length: 8,
      contains_digit: true,
      contains_uppercase: true,
      contains_lowercase: true,
      contains_special: true
    }

    password.to_s.match?(PASSWORD_FORMAT) &&
      complexity_requirements[:min_length] <= password.length &&
      complexity_requirements[:contains_digit] && password.count("0-9") > 0 &&
      complexity_requirements[:contains_uppercase] && password.count("A-Z") > 0 &&
      complexity_requirements[:contains_lowercase] && password.count("a-z") > 0 &&
      complexity_requirements[:contains_special] && password.count("^a-zA-Z0-9") > 0
  end

  def autofill_hints_compatible?(password_management_tool)
    # This is a placeholder method. You should implement checks based on the specific requirements
    # of the password management tool you are integrating with.
    # For example, check if the autofill hints are supported:
    password_management_tool.autofill_hints_supported?
  end

  def confirm_email!
    self.email_confirmed = true
    save!
  rescue ActiveRecord::RecordInvalid => e
    raise ActiveRecord::RecordInvalid, "Email confirmation failed: #{e.record.errors.full_messages.join(', ')}"
  end

  # Other instance methods...

  private

  def send_confirmation_email(token)
    DeviseMailer.resend_confirmation_instructions(self, token).deliver_now
  end
end
