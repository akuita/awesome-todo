# typed: strict

class SendConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    # Use the Devise mailer to send confirmation instructions
    user.send_confirmation_instructions
  end
end

