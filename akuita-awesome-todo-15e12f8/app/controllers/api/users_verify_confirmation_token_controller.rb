class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise  Exceptions::AuthenticationError if client.blank?

    token = EmailConfirmationToken.find_and_validate_token(params.dig(:confirmation_token))
    if token
      user = token.user
      user.confirm_email
      render json: { message: I18n.t('email_login.confirmations.success') }, status: :ok
    else
      render json: { error_message: I18n.t('email_login.confirmations.invalid_or_expired_token') }, status: :not_found
    end
  end
end
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
end
