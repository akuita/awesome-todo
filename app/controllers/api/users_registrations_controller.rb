class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create

  def create
    @user = User.new(create_params)
    if @user.save
      EmailConfirmation.create_confirmation_record(@user.id) # New code addition
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

  private

  def check_email_availability
    email = params[:user][:email]
    if User.exists?(email: email)
      render json: { message: I18n.t('common.422'), error: 'Email is already taken' }, status: :unprocessable_entity and return
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
