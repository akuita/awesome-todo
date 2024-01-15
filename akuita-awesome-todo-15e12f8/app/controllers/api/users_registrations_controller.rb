
class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_format, only: :create

  def validate_email_format
    email = params[:user][:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: I18n.t('activerecord.errors.messages.invalid_email_format') }, status: :unprocessable_entity
      return false
    end
    true
  end

  def create
    return unless validate_email_format
    
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
