
class ResendConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(user, token)
    user = User.find_by(email: email)
    if user && !user.email_confirmed
      token_record = user.email_confirmation_token
      if token_record.nil? || token_record.created_at < 2.minutes.ago
        user.regenerate_confirmation_token
        # Update the token passed to the mailer with the new token
        new_token = user.email_confirmation_token.token
        Devise::Mailer.confirmation_instructions(user, new_token).deliver_later
      else
        raise StandardError.new "You must wait a bit longer before requesting another confirmation email."
      end
    end
  end
end
