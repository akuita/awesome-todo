# typed: strict
class ResendConfirmationEmailJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(*args)
    # Determine if the job received user_id or email as the identifier
    if args.size == 1 && args.first.is_a?(String)
      perform_with_email(*args)
    elsif args.size == 2
      perform_with_user_id_and_token(*args)
    else
      raise ArgumentError, "Invalid arguments for ResendConfirmationEmailJob"
    end
  end

  private

  def perform_with_email(email)
    user = User.find_by(email: email)
    if user && !user.email_confirmed
      email_confirmation = user.email_confirmation
      if email_confirmation.nil? || email_confirmation.created_at < 2.minutes.ago
        user.regenerate_confirmation_token # Assuming this method also sets the created_at
        Devise::Mailer.confirmation_instructions(user, user.confirmation_token).deliver_later
      else
        raise I18n.t('devise.errors.messages.too_soon')
      end
    end

    Rails.logger.info "ResendConfirmationEmailJob: Confirmation email sent to user #{user.email}" if user
  end

  def perform_with_user_id_and_token(user_id, token)
    user = User.find_by(id: user_id)
    return if user.nil? || user.email.blank?

    user.regenerate_confirmation_token
    Devise::Mailer.confirmation_instructions(user, token).deliver_later

    Rails.logger.info "ResendConfirmationEmailJob: Confirmation email sent to user #{user.email}"
  end
end
