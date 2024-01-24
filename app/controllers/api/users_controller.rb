class Api::UsersController < Api::BaseController
  before_action :set_user, only: [:integrate_password_management_tool, :resend_confirmation]
  before_action :validate_token, only: [:confirm_email]

  SUPPORTED_TOOLS = %w[1Password iCloudPassword].freeze

  # existing actions

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

  def resend_confirmation
    email = params[:email]

    return render json: { error: I18n.t('controller.users.email_required') }, status: :bad_request unless email.present?
    return render json: { error: I18n.t('controller.users.invalid_email') }, status: :unprocessable_entity unless email =~ URI::MailTo::EMAIL_REGEXP

    user = User.find_by(email: email)
    return render json: { error: I18n.t('devise.failure.not_found_in_database') }, status: :not_found if user.nil?
    return render json: { error: I18n.t('devise.failure.already_confirmed') }, status: :unprocessable_entity if user.email_confirmed

    last_sent_time = EmailConfirmation.last_confirmation_sent_for(email)
    if last_sent_time && Time.now.utc < last_sent_time + 2.minutes
      return render json: { error: I18n.t('controller.users.resend_email_too_soon') }, status: :too_many_requests
    end

    if user.regenerate_confirmation_token
      Devise::Mailer.confirmation_instructions(user, user.confirmation_token).deliver_later
      render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
    else
      render json: { error: I18n.t('errors.messages.not_saved', resource: 'confirmation token') }, status: :internal_server_error
    end
  end

  def confirm_email
    token = params[:token]
    result = User.confirm_by_token(token)

    if result[:error].present?
      message = result[:error] == 'Token not found' ? 'Invalid or expired email confirmation token.' : result[:error]
      status = result[:error] == 'Token not found' ? :not_found : :gone
      render json: { error: message }, status: status
    else
      render json: { message: 'Email address confirmed successfully.' }, status: :ok
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def validate_token
    render json: { error: 'Token is required' }, status: :bad_request unless params[:token].present?
  end

  def set_user
    @user = User.find_by(id: params[:user_id] || params[:email])
    render json: { message: I18n.t('controller.users.user_not_found') }, status: :not_found unless @user
  end

  # other private methods
end
