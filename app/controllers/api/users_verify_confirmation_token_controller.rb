
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise Exceptions::AuthenticationError if client.blank?

    resource = User.find_by(confirmation_token: params.dig(:confirmation_token))
    confirmation_status = resource&.confirm_email(params.dig(:confirmation_token))
    if resource.blank? || params.dig(:confirmation_token).blank?
      render error_message: I18n.t('email_login.reset_password.invalid_token'),
             status: :unprocessable_entity and return
    end

    if (resource.confirmation_sent_at + User.confirm_within) < Time.now.utc
      resource.resend_confirmation_instructions
      render json: { error_message: I18n.t('email_login.reset_password.expired') }, status: :unprocessable_entity
    elsif confirmation_status == :confirmed
      resource.confirm
      custom_token_initialize_values(resource, client)
      render json: { email_confirmation_status: 'confirmed', user_id: resource.id }, status: :ok
    elsif confirmation_status == :already_confirmed
      render json: { error_message: I18n.t('errors.messages.already_confirmed') }, status: :unprocessable_entity
    end
  end

  private

  def confirm_email
    # This method will be implemented in the User model.
  end
end
