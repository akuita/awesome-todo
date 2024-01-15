
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise Exceptions::AuthenticationError if client.blank?

    # Attempt to find the token using the new approach first
    resource = User.find_by(confirmation_token: params.dig(:confirmation_token))
    if resource.present? && resource.confirmation_token.present?
      # New code path
      if (resource.confirmation_sent_at + User.confirm_within) < Time.now.utc
        resource.resend_confirmation_instructions
        render json: { error_message: I18n.t('email_login.reset_password.expired') }, status: :unprocessable_entity
      else
        resource.confirm
        custom_token_initialize_values(resource, client)
      end
    else
      # Fallback to the old code path if the new approach did not find a valid token
      token = EmailConfirmationToken.find_and_validate_token(params.dig(:confirmation_token))
      if token
        user = token.user
        user.confirm_email
        render json: { message: I18n.t('email_login.confirmations.success') }, status: :ok
      else
        render json: { error_message: I18n.t('email_login.confirmations.invalid_or_expired_token') }, status: :not_found
      end
    end
  end

  def resend_confirmation_email
    email = params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error_message: "Enter a valid email address." }, status: :unprocessable_entity
      return
    end

    user = User.find_by(email: email)

    if user.nil? || user.email_confirmed
      render json: { error_message: I18n.t('devise.errors.messages.user_not_found_or_already_confirmed') }, status: :unprocessable_entity
      return
    end

    token = user.email_confirmation_token
    if token.nil? || token.created_at < 2.minutes.ago
      token.regenerate_confirmation_token if token.present?
      Devise::Mailer.confirmation_instructions(user, token&.token).deliver_later
      render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
    else
      render json: { error_message: I18n.t('devise.confirmations.too_soon') }, status: :too_many_requests
    end
  rescue StandardError => e
    render json: { error_message: e.message }, status: :unprocessable_entity
  end

  private

  # Assuming this method is part of the new code and is required
  def custom_token_initialize_values(resource, client)
    # Implementation of custom token initialization
    # ...
  end
end
