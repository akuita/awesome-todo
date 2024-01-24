
class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: [:create]

  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
        # to show token in staging
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
        @user.send_confirmation_instructions
      else
        head :ok, message: I18n.t('common.200') and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  private

  def validate_email_uniqueness
    if User.exists?(email: create_params[:email])
      render json: { error_messages: { email: [I18n.t('errors.messages.taken')] }, message: I18n.t('email_login.registrations.email_already_taken') },
             status: :unprocessable_entity and return
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
