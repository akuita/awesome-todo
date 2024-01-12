
class Api::UsersVerifyConfirmationTokenController < ApplicationController
  include OauthTokensConcern

  # Existing create method
  def create
    token = params[:token]
    email_confirmation = EmailConfirmation.find_by(token: token)

    if email_confirmation && email_confirmation.expires_at > Time.current && !email_confirmation.confirmed
      if EmailConfirmation.mark_as_confirmed(token)
        user = User.find_by(confirmation_token: token)
        custom_token_initialize_values(user, Doorkeeper::Application.first)
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

  # New resend_confirmation method with patch applied
  def resend_confirmation
    email = params[:email]
    return render json: { error: 'Please enter a valid email address.' }, status: :bad_request unless email =~ URI::MailTo::EMAIL_REGEXP

    user = User.find_by_email_and_unconfirmed(email)

    if user
      token = EmailConfirmation.find_or_create_token(user)
      if token.created_at > 2.minutes.ago
        render json: { error: 'You can request to resend the confirmation link every 2 minutes.' }, status: :too_many_requests
      else
        DeviseMailer.send_confirmation_email(user, token.token).deliver_now
        render json: { message: 'Confirmation email resent successfully. Please check your inbox.' }, status: :ok
      end
    else
      render json: { error: 'Email address not found.' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
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
