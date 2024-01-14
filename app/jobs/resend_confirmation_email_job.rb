# typed: strict
class ResendConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return if user.nil?

    user.regenerate_confirmation_token
    Devise::Mailer.confirmation_instructions(user, user.confirmation_token).deliver_later

    Rails.logger.info "ResendConfirmationEmailJob: Confirmation email sent to user #{user.email}"
  end
end
