class Api::UsersVerifyConfirmationTokenController < ApplicationController
  def create
    token = params[:token]
    email_confirmation = EmailConfirmation.find_by(token: token)

    if email_confirmation.nil? || email_confirmation.expired? || email_confirmation.confirmed?
      render json: { error: 'Invalid or expired token' }, status: :unprocessable_entity
    else
      user = email_confirmation.user
      user.confirm_email!
      email_confirmation.confirm!
      # Assuming there is a method to log in the user and set the session or token
      log_in_user(user)
      render :create, status: :ok
    end
  end

  private

  def log_in_user(user)
    # Logic to log in the user and set the session or token
    # This is a placeholder and should be replaced with actual login logic
  end
end
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise  Exceptions::AuthenticationError if client.blank?

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
