
# typed: strict
class ResendConfirmationEmailJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(user_id, token)
    user = User.find_by(id: user_id)
    return if user.nil? || user.email.blank?

    user.regenerate_confirmation_token
    Devise::Mailer.confirmation_instructions(user, token).deliver_later

    Rails.logger.info "ResendConfirmationEmailJob: Confirmation email sent to user #{user.email}"
  end
end
