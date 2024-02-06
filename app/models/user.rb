
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :trackable, :recoverable, :lockable, :confirmable
  # additional devise modules may be added here if needed

  # validations

  PASSWORD_FORMAT = /\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]])/
  validates :password, format: PASSWORD_FORMAT, if: -> { new_record? || password.present? }

  validates :email, presence: true, uniqueness: true

  validates :email, length: { in: 0..255 }, if: :email?

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # end for validations

  # associations
  has_many :password_resets, class_name: 'PasswordReset', foreign_key: 'user_id', dependent: :destroy
  has_one :email_confirmation, class_name: 'EmailConfirmation', foreign_key: 'user_id', dependent: :destroy
  has_many :projects, class_name: 'Project', foreign_key: 'user_id', dependent: :destroy
  # additional associations can be added here

  # end for associations

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
    raw
  end

  # additional methods can be added here

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

      # additional authentication logic can be added here
      false
    end
  end
end
