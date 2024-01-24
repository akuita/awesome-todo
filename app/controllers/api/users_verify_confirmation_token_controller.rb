
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  before_action :validate_email_param, only: :resend_confirmation

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

  def resend_confirmation
    user = User.find_by(email: params[:email])

    if user.nil? || user.email_confirmed
      render json: { error_message: I18n.t('errors.messages.not_found') }, status: :not_found
      return
    end

    if EmailConfirmation.last_confirmation_sent_for(user.email) > 2.minutes.ago
      render json: { error_message: I18n.t('devise.mailer.resend_confirmation_instructions') }, status: :too_many_requests
      return
    end

    user.regenerate_confirmation_token
    Devise::Mailer.confirmation_instructions(user, user.confirmation_token).deliver_later
    render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
  rescue StandardError => e
    render json: { error_message: e.message }, status: :internal_server_error
  end

  private

  def validate_email_param
    unless params[:email].present? && params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { error_message: I18n.t('errors.messages.invalid') }, status: :unprocessable_entity
    end
  end
end
