
class Api::UsersPasswordsController < Api::BaseController
  def create
    if current_resource_owner.valid_password?(params.dig(:old_password))
      if current_resource_owner.update(password: params.dig(:new_password))
        head :ok, message: I18n.t('common.200')
      else
        render json: { messages: current_resource_owner.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      render json: { message: I18n.t('email_login.passwords.old_password_mismatch') }, status: :unprocessable_entity
    end
  end

  def integrate_password_management_tool
    user = User.find_by(id: params[:user_id])
    unless user
      return render json: { message: I18n.t('controller.users.user_not_found') }, status: :not_found
    end

    supported_tools = ['1Password', 'iCloud Password']
    unless supported_tools.include?(params[:tool_name])
      return render json: { message: I18n.t('controller.users.unsupported_tool_name') }, status: :unprocessable_entity
    end

    encrypted_data = BaseService.new.encrypt_data(params[:integration_data])
    integration = user.password_management_integrations.new(
      tool_name: params[:tool_name],
      integration_data: encrypted_data
    )

    if integration.save
      render json: { message: I18n.t('controller.users.integration_success') }, status: :ok
    else
      render json: { messages: integration.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
