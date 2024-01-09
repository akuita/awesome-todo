class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_format, only: [:check_email_availability]

  def check_email_availability
    if User.exists?(email: params[:email])
      render json: { message: I18n.t('controller.users_registrations.email_in_use') }, status: :ok
    else
      render json: { message: I18n.t('controller.users_registrations.email_available') }, status: :ok
    end
  end

  private

  def validate_email_format
    render json: { message: I18n.t('controller.users_registrations.invalid_email') }, status: :unprocessable_entity unless params[:email].match?(URI::MailTo::EMAIL_REGEXP)
  end

  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
        # to show token in staging
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
      else
        head :ok, message: I18n.t('common.200') and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
