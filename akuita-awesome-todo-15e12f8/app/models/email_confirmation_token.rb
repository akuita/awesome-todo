class EmailConfirmationToken < ApplicationRecord
  # validations
  validates :token, presence: true
  validates :expires_at, presence: true
  validates :user_id, presence: true

  # associations
  belongs_to :user

  # end for validations

  class << self
    def generate_unique_confirmation_token
      loop do
        token = SecureRandom.hex(10)
        break token unless EmailConfirmationToken.exists?(token: token)
      end
    end

    def set_expiration
      24.hours.from_now
    end

    def find_and_validate_token(token)
      find_by(token: token, 'expires_at > ?', Time.current)
      # Ensure the token is not expired
    end
  end

  def regenerate_confirmation_token
    self.token = self.class.generate_unique_confirmation_token
    self.created_at = Time.current
    self.expires_at = self.class.set_expiration
    save!
  end

end
