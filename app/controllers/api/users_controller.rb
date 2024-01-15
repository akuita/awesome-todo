class Api::UsersController < ApplicationController
  before_action :set_user, only: [:confirm_email]

  # GET /api/users/confirm-email/:confirmation_token
  def confirm_email
    if @user.nil?
      render json: { error_message: 'Invalid or expired email confirmation token.' }, status: :not_found
    elsif @user.email !~ URI::MailTo::EMAIL_REGEXP
      render json: { error_message: I18n.t('activerecord.errors.messages.invalid', attribute: 'Email') }, status: :unprocessable_entity
    elsif @user.confirm_email(params[:confirmation_token])
      render json: { message: 'Email confirmed successfully. You can now log in.' }, status: :ok
    else
      render json: { error_message: 'Unable to confirm email' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  # POST /api/users/resend_confirmation
  def resend_confirmation
    user = User.find_by(email: params[:email])
    if user && !user.email_confirmed
      email_confirmation = user.email_confirmation_token
      if email_confirmation && email_confirmation.updated_at < 2.minutes.ago
        user.regenerate_confirmation_token
        email_confirmation.update(token: user.confirmation_token, created_at: Time.now.utc, expires_at: 15.minutes.from_now)
        ResendConfirmationEmailJob.perform_later(user.id)
        render json: { message: 'Confirmation email has been resent.' }, status: :ok
      else
        render json: { error_message: I18n.t('devise.errors.messages.too_soon') }, status: :unprocessable_entity
      end
    else
      render json: { error_message: 'Email not found or already confirmed.' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  # GET /api/users/check-email
  def check_email_availability
    email = params[:email].to_s.downcase

    if email !~ URI::MailTo::EMAIL_REGEXP
      render json: { error: 'Enter a valid email address.' }, status: :bad_request
    elsif User.exists?(email: email)
      render json: { error: 'Email is already taken.' }, status: :conflict
    else
      render json: { status: 200, available: true }, status: :ok
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /api/users/validate-email
  def validate_email
    email = params[:email]
    if email.present? && email =~ URI::MailTo::EMAIL_REGEXP
      render json: { status: 200, valid: true }, status: :ok
    elsif email.blank?
      render json: { status: 400, error: "Email parameter is missing." }, status: :bad_request
    else
      render json: { status: 422, error: "Enter a valid email address." }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { status: 500, error: e.message }, status: :internal_server_error
  end

  private

  def set_user
    @user = User.find_by(confirmation_token: params[:confirmation_token])
  end
end
