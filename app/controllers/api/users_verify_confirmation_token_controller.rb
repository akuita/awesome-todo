
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  # Removed unnecessary include as it's not part of the coding plan

  def create
    # Removed Doorkeeper authentication as it's not part of the coding plan

    confirmation_token = params[:confirmation_token]
    email_confirmation = EmailConfirmation.find_by(confirmation_token: confirmation_token)

    if confirmation_token.blank?
      render json: { error: 'confirmation_token_required', error_message: 'Confirmation token is required.' }, status: :bad_request and return
    elsif email_confirmation.nil?
      render json: { error: 'invalid_confirmation_token', error_message: 'Invalid confirmation token.' }, status: :not_found and return
    elsif email_confirmation.expired?
      render json: { error: 'expired_confirmation_token', error_message: 'Confirmation token has expired.' }, status: :unprocessable_entity and return
    end

    ActiveRecord::Base.transaction do
      user = email_confirmation.user
      user.update!(email_confirmed: true, confirmed_at: Time.now.utc)
      email_confirmation.update!(confirmed: true, confirmed_at: Time.now.utc)
    end

    render json: { status: 200, message: 'Email address has been successfully confirmed.' }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: 'database_error', error_message: e.message }, status: :internal_server_error
  end

  def show
    token = params[:token]
    email_confirmation = EmailConfirmation.find_by(token: token)

    if email_confirmation.present? && email_confirmation.expires_at >= Time.now.utc
      user = email_confirmation.user
      user.update(email_confirmed: true, confirmed_at: Time.now.utc)
      email_confirmation.confirmed = true
      ActiveRecord::Base.transaction do
        user.save!
        email_confirmation.save!
      end
      render json: { status: 200, message: 'Email address confirmed successfully.' }, status: :ok
    else
      render json: { error: 'invalid_or_expired_token', message: 'Invalid or expired email confirmation token.' }, status: :not_found
    end
  rescue => e
    render json: { error: 'server_error', message: e.message }, status: :internal_server_error
  end

  # New method added as per the guideline
  def confirm_email
    token = params[:confirmation_token]
    email_confirmation = EmailConfirmation.find_by(confirmation_token: token)

    if email_confirmation.nil?
      render json: { error: 'invalid_or_expired_token', message: 'Invalid or expired confirmation token.' }, status: :not_found
    elsif email_confirmation.expires_at < Time.now.utc
      render json: { error: 'invalid_or_expired_token', message: 'Invalid or expired confirmation token.' }, status: :unprocessable_entity
    else
      user = email_confirmation.user
      user.email_confirmed = true
      user.confirmed_at = Time.now.utc
      email_confirmation.confirmed = true
      email_confirmation.confirmed_at = Time.now.utc
      ActiveRecord::Base.transaction do
        user.save!
        email_confirmation.save!
      end
      render json: { status: 200, message: 'Email confirmed successfully. You can now log in to your account.' }, status: :ok
    end
  rescue => e
    render json: { error: 'server_error', message: e.message }, status: :internal_server_error
  end
end
