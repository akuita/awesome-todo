class EmailConfirmation < ApplicationRecord
  belongs_to :user

  def self.create_for_user(user)
    create!(
      user: user,
      token: SecureRandom.hex(10),
      expires_at: 48.hours.from_now,
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  def self.mark_as_confirmed(token)
    email_confirmation = find_by(token: token)
    if email_confirmation && !email_confirmation.confirmed && email_confirmation.expires_at > Time.current
      user = email_confirmation.user
      user.email_confirmed = true
      EmailConfirmation.transaction do
        user.save!
        email_confirmation.update!(confirmed: true, updated_at: Time.current)
      end
      true
    else
      false
    end
  rescue => e
    false
  end

  def self.find_or_create_token(user)
    recent_token = user.email_confirmations.order(created_at: :desc).first
    if recent_token.nil? || recent_token.expires_at < Time.current
      token = SecureRandom.hex(10)
      create!(
        user: user,
        token: token,
        expires_at: Time.current + 10.minutes,
        confirmed: false
      )
    else
      recent_token
    end
  end
end
