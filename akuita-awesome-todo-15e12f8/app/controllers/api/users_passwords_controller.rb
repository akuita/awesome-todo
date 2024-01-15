class Api::UsersPasswordsController < Api::BaseController
  def create
    unless current_resource_owner.email =~ URI::MailTo::EMAIL_REGEXP
      render json: { message: "Enter a valid email address." }, status: :unprocessable_entity
      return
    end

    if current_resource_owner.valid_password?(params.dig(:old_password))
      if current_resource_owner.update(password: params.dig(:new_password))
        head :ok, message: I18n.t('common.200')
      else
        render json: { messages: current_current_resource_owneruser.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      render json: { message: I18n.t('email_login.passwords.old_password_mismatch') }, status: :unprocessable_entity
    end
  end
end
