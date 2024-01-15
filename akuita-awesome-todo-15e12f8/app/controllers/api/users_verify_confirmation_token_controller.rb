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
    user = User.find_by(email: email)

    if user.nil?
      render json: { error_message: I18n.t('devise.errors.messages.user_not_found') }, status: :not_found
      return
    end

    begin
      ResendConfirmationEmailJob.perform_later(email)
      render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
    rescue StandardError => e
      render json: { error_message: e.message }, status: :unprocessable_entity
    end
  end

  private

  # Assuming this method is part of the new code and is required
  def custom_token_initialize_values(resource, client)
    # Implementation of custom token initialization
    # ...
  end
end
