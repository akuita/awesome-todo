
class Api::UsersController < ApplicationController
  before_action :set_user, only: [:confirm_email]

  # GET /api/users/confirm-email/:confirmation_token
  def confirm_email
    email_confirmation = @user.email_confirmations.find_by(token: params[:confirmation_token]) if @user
    if @user.nil? || email_confirmation.nil? || email_confirmation.expired?
      render json: { error_message: 'Invalid or expired email confirmation token.' }, status: :not_found
    elsif @user.email !~ URI::MailTo::EMAIL_REGEXP
      render json: { error_message: I18n.t('activerecord.errors.messages.invalid', attribute: 'Email') }, status: :unprocessable_entity
    elsif email_confirmation && email_confirmation.confirm_email
      render json: { message: 'Email address confirmed successfully.' }, status: :ok
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
      email_confirmation = user.email_confirmations.last
      if email_confirmation.nil? || email_confirmation.created_at < 2.minutes.ago
        ResendConfirmationEmailJob.perform_later(user.email)
        render json: { message: I18n.t('common.confirmation_resent', email: user.email) }, status: :ok
      else
        render json: { error_message: I18n.t('errors.messages.too_soon') }, status: :too_many_requests
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
