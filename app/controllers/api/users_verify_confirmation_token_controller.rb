
class Api::UsersVerifyConfirmationTokenController < ApplicationController
  # Existing create method
  def create
    # Updated code according to the guidelines
    token = params[:token]
    email_confirmation = EmailConfirmation.find_by(token: token)

    if email_confirmation && email_confirmation.expires_at > Time.current && !email_confirmation.confirmed
      user = email_confirmation.user
      if user.update(email_confirmed: true)
        email_confirmation.update!(confirmed: true, updated_at: Time.current)
        custom_token_initialize_values(user, client)
        render json: {
          message: 'Email successfully confirmed and user signed in.',
          access_token: @access_token,
          token_type: @token_type,
          expires_in: @expires_in,
          refresh_token: @refresh_token,
          resource_owner: @resource_owner,
          resource_id: @resource_id,
          created_at: @created_at,
          refresh_token_expires_in: @refresh_token_expires_in,
          scope: @scope
        }, status: :ok
      else
        render json: { error: 'Unable to confirm email.' }, status: :unprocessable_entity
      end
    else
      error_message = email_confirmation.nil? ? 'Invalid token.' : 'Token expired or email already confirmed.'
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

  private

  # ... existing private methods ...

  def custom_token_initialize_values(user, client)
    # Assuming this method initializes and sets instance variables for the token response
    # This is a placeholder implementation. The actual implementation will depend on the authentication system being used.
    @access_token = "generated_access_token"
    @token_type = "Bearer"
    @expires_in = 7200 # 2 hours in seconds
    @refresh_token = "generated_refresh_token"
    @resource_owner = user.email
    @resource_id = user.id
    @created_at = Time.current.to_i
    @refresh_token_expires_in = 604800 # 1 week in seconds
    @scope = "public"
  end
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
