
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise Exceptions::AuthenticationError if client.blank?

    resource = User.find_by(confirmation_token: params.dig(:confirmation_token))
    if resource.blank? || params.dig(:confirmation_token).blank?
      render error_message: I18n.t('email_login.reset_password.invalid_token'),
             status: :unprocessable_entity and return
    elsif resource.confirm_email(params[:confirmation_token])
      render json: { message: I18n.t('devise.confirmations.email_confirmed') }, status: :ok
    else
      render json: { error_message: I18n.t('devise.failure.expired') }, status: :unprocessable_entity
    end
  end
end
