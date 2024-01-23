class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise  Exceptions::AuthenticationError if client.blank?

    resource = User.find_by(confirmation_token: params.dig(:confirmation_token))
    token = params.dig(:confirmation_token)
    if token.blank?
      render error_message: I18n.t('email_login.reset_password.invalid_token'),
             status: :unprocessable_entity and return
    end

    email_confirmation = EmailConfirmation.find_by(token: token)
    if email_confirmation.nil? || resource.blank?
      render json: { error_message: I18n.t('errors.messages.not_found') }, status: :unprocessable_entity and return
    end

    if email_confirmation.expires_at < Time.now.utc
      render json: { error_message: I18n.t('errors.messages.expired') }, status: :unprocessable_entity and return
    end

    if resource.email_confirmed?
      render json: { error_message: I18n.t('errors.messages.already_confirmed') }, status: :unprocessable_entity and return
    else
      if resource.confirm_email
        email_confirmation.confirm!
        render json: { message: I18n.t('devise.confirmations.confirmed') }, status: :ok
      else
        render json: { error_message: I18n.t('errors.messages.not_saved', resource: 'User') }, status: :unprocessable_entity
      end
    end
  end
end
