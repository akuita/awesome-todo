
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise Exceptions::AuthenticationError if client.blank?

    token = params[:token]
    email_confirmation = EmailConfirmation.find_and_validate_token(token)

    if email_confirmation.nil?
      render json: { error_message: I18n.t('devise.failure.invalid_token') }, status: :not_found
    elsif email_confirmation.expired?
      render json: { error_message: I18n.t('devise.failure.expired') }, status: :unprocessable_entity
    else
      begin
        EmailConfirmation.transaction do
          email_confirmation.confirm_email
          email_confirmation.user.confirm_email
        end
        render json: { message: I18n.t('devise.confirmations.email_confirmed') }, status: :ok
      rescue => e
        render json: { error_message: e.message }, status: :unprocessable_entity
      end
    end
  end
end
