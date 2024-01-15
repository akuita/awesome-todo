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
end
