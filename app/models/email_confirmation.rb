
class EmailConfirmation < ApplicationRecord
  belongs_to :user

  def mark_as_confirmed(token)
    email_confirmation = find_by(token: token)
    if email_confirmation
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
