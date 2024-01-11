class Api::UsersVerifyConfirmationTokenController < ApplicationController
  # Existing create method
  def create
    token = params[:token]
    user = User.find_by(confirmation_token: token)

    if user&.confirmable? && user.confirmed_at.nil?
      user.confirm
      sign_in(user)
      render json: { message: 'Email successfully confirmed and user signed in.' }, status: :ok
    else
      error_message = user.nil? ? 'Invalid token.' : 'Token expired or user already confirmed.'
      render json: { error: error_message }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # New resend_confirmation method
  def resend_confirmation
    email = params[:email]
    if email.match?(URI::MailTo::EMAIL_REGEXP)
      user = User.find_by(email: email)
      if user
        user.resend_confirmation_instructions
        render json: { message: 'Confirmation email resent successfully.' }, status: :ok
      else
        render json: { error: 'Email address not found.' }, status: :not_found
      end
    else
      render json: { error: 'Invalid email format.' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # ... existing private methods ...
end

class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  # Existing create method
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise Exceptions::AuthenticationError if client.blank?

    resource = User.find_by(confirmation_token: params.dig(:confirmation_token))
    if resource.blank? || params.dig(:confirmation_token).blank?
      render error_message: I18n.t('email_login.reset_password.invalid_token'),
             status: :unprocessable_entity and return
    end

    if (resource.confirmation_sent_at + User.confirm_within) < Time.now.utc
      resource.resend_confirmation_instructions
      render json: { error_message: I18n.t('email_login.reset_password.expired') }, status: :unprocessable_entity
    else
      resource.confirm
      custom_token_initialize_values(resource, client)
    end
  end
end
