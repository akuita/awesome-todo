
class Api::UsersController < Api::BaseController
  before_action :set_user, only: [:integrate_password_management_tool]

  SUPPORTED_TOOLS = %w[1Password iCloudPassword].freeze

  def integrate_password_management_tool
    tool_name = params[:tool_name]
    integration_data = params[:integration_data]

    unless SUPPORTED_TOOLS.include?(tool_name)
      return render json: { message: I18n.t('controller.users.unsupported_tool_name') }, status: :unprocessable_entity
    end

    integration = @user.password_management_integrations.new(
      tool_name: tool_name,
      integration_data: BaseService.encrypt_data(integration_data)
    )

    if integration.save
      render json: { message: I18n.t('controller.users.integration_success') }, status: :ok
    else
      render json: { messages: integration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:user_id])
    render json: { message: I18n.t('controller.users.user_not_found') }, status: :not_found unless @user
  end
end
