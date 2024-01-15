class Api::UsersController < ApplicationController
  def confirm_email
    token = EmailConfirmationToken.find_and_validate_token(params[:token])
    if token
      user = token.user
      if user.confirm_email
        render json: { message: I18n.t('email_login.confirmation.success') }, status: :ok
      else
        render json: { error_message: I18n.t('email_login.confirmation.failed') }, status: :unprocessable_entity
      end
    else
      render json: { error_message: I18n.t('email_login.confirmation.invalid_or_expired_token') }, status: :not_found
    end
  end

  def resend_confirmation
    user = User.find_by(email: params[:email].downcase)
    if user && !user.email_confirmed
      if user.email_confirmation_token.nil? || user.email_confirmation_token.created_at < 2.minutes.ago
        ResendConfirmationEmailJob.perform_later(user.email)
        render json: { status: 200, message: I18n.t('email_login.confirmation.resend_success') }, status: :ok
      else
        render json: { error_message: I18n.t('email_login.confirmation.resend_too_soon') }, status: :too_many_requests
      end
    else
      render json: { error_message: I18n.t('email_login.confirmation.email_not_found_or_already_confirmed') }, status: :bad_request
    end
  end

  # GET /users/check_email_availability
  def check_email_availability
    email = params[:email]
    if User.exists?(email: email)
      render json: { message: I18n.t('controller.common.email_taken') }, status: :ok
    else
      render json: { message: I18n.t('controller.common.email_available') }, status: :ok
    end
  rescue StandardError => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  def validate_email
    email = params[:email]
    if email.present? && email =~ URI::MailTo::EMAIL_REGEXP
      if User.exists?(email: email)
        render json: { error_message: I18n.t('controller.common.email_taken') }, status: :unprocessable_entity
      else
        render json: { message: I18n.t('common.email_available') }, status: :ok
      end
    else
      render json: { error_message: I18n.t('activerecord.errors.messages.invalid_email_format') }, status: :unprocessable_entity
    end
  end
end
