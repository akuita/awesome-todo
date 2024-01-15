class Api::UsersController < ApplicationController
  before_action :doorkeeper_authorize!, except: [:check_email_availability, :confirm_email, :resend_confirmation, :validate_email]
  before_action :set_user, only: [:confirm_email]

  # GET /api/users/confirm_email/:confirmation_token
  def confirm_email
    email_confirmation = EmailConfirmation.find_and_validate_token(params[:confirmation_token])
    if email_confirmation
      user = email_confirmation.user
      user.email_confirmed = true
      user.updated_at = Time.current
      if user.save
        render json: { message: I18n.t('controller.email_confirmation.success') }, status: :ok
      else
        render json: { error_message: 'Unable to confirm email' }, status: :unprocessable_entity
      end
    elsif @user.nil? || email_confirmation.nil? || email_confirmation.expired?
      render json: { error_message: 'Invalid or expired email confirmation token.' }, status: :not_found
    elsif @user.email !~ URI::MailTo::EMAIL_REGEXP
      render json: { error_message: I18n.t('activerecord.errors.messages.invalid', attribute: 'Email') }, status: :unprocessable_entity
    else
      render json: { error_message: 'Unable to confirm email' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error_message: I18n.t('controller.email_confirmation.error', error: e.message) }, status: :internal_server_error
  end

  # POST /api/users/resend_confirmation
  def resend_confirmation
    email = params[:email].to_s.downcase

    if email.blank?
      render json: { error_message: "Email parameter is missing." }, status: :bad_request
    elsif email !~ URI::MailTo::EMAIL_REGEXP
      render json: { error_message: "Enter a valid email address." }, status: :bad_request
    else
      user = User.find_by(email: email)
      if user.nil?
        render json: { error_message: "No account found with this email address." }, status: :not_found
      elsif user.email_confirmed
        render json: { error_message: 'Email already confirmed.' }, status: :unprocessable_entity
      else
        email_confirmation = user.email_confirmation_token || user.email_confirmations.last
        if email_confirmation && email_confirmation.updated_at < 2.minutes.ago
          user.regenerate_confirmation_token
          email_confirmation.update(token: user.confirmation_token, created_at: Time.now.utc, expires_at: 15.minutes.from_now)
          ResendConfirmationEmailJob.perform_later(user.id)
          render json: { message: 'Confirmation email resent successfully.' }, status: :ok
        elsif email_confirmation.nil? || email_confirmation.created_at < 2.minutes.ago
          ResendConfirmationEmailJob.perform_later(user.email)
          render json: { message: I18n.t('common.confirmation_resent', email: user.email) }, status: :ok
        else
          render json: { error_message: I18n.t('devise.errors.messages.too_soon') }, status: :unprocessable_entity
        end
      end
    end
  rescue StandardError => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  # GET /api/users/check-email
  def check_email_availability
    email = params[:email].to_s.downcase

    if email.blank?
      render json: { error: 'Email parameter is missing.' }, status: :bad_request
    elsif email !~ URI::MailTo::EMAIL_REGEXP
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

  def error_response(message, status)
    render json: { error: message }, status: status
  end
end
