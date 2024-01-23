
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable,
         :confirmable,
         :trackable, :recoverable, :lockable

  # validations
  # ... (Assuming there are validations here, but they are not shown in the patch or the original code)

  # associations
  has_many :email_confirmations, foreign_key: :user_id, dependent: :destroy

  # Custom logic related to email confirmations
  def email_confirmed?
    email_confirmations.where(confirmed: true).exists?
  end

  # end for validations

  def generate_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)
  end

  # ... (Assuming there might be more methods or logic here, but they are not shown in the patch or the original code)
end
