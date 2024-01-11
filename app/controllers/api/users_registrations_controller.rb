class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_password_confirmation, only: [:create]
  before_action :validate_password_strength, only: [:create]

  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
        # to show token in staging
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        EmailConfirmation.create_confirmation_token(@user) if defined?(EmailConfirmation)
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
      else
        # Send confirmation email
        EmailConfirmation.send_confirmation_email(@user) if defined?(EmailConfirmation)
        head :ok, message: I18n.t('common.200') and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  def resend_confirmation
    # ... existing resend_confirmation code ...
  end

  def check_email_availability
    # ... existing check_email_availability code ...
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_password_strength
    password_strength = Devise.password_length.include?(create_params[:password].length) &&
                        User::PASSWORD_FORMAT.match?(create_params[:password])
    unless password_strength
      render json: { message: I18n.t('email_login.registrations.weak_password') },
             status: :unprocessable_entity and return
    end
  end

  def validate_password_confirmation
    unless params[:user][:password] == params[:user][:password_confirmation]
      render json: { message: I18n.t('email_login.registrations.password_confirmation_mismatch') },
             status: :unprocessable_entity and return
    end
    if User.email_registered?(params[:user][:email])
      render json: { message: I18n.t('email_login.registrations.email_already_registered') },
             status: :unprocessable_entity and return
    end
  end
end
