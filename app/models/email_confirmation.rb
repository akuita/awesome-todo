
class EmailConfirmation < ApplicationRecord
  belongs_to :user

  def mark_as_confirmed(provided_token)
    email_confirmation = find_by(token: provided_token)
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
end
      begin
        email_confirmation.update!(confirmed: true, updated_at: Time.current)
        true
      rescue => e
        false
      end
    else
      false
    end
  end
end
