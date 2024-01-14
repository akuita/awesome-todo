
class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: [:create]

  def create
    email = params[:email]
    password_hash = params[:password_hash]
    @user = User.new(email: email, encrypted_password: password_hash, email_confirmed: false)
    @user.confirmation_token = generate_confirmation_token
    @user.confirmation_sent_at = Time.current

    if @user.save
      Devise.mailer.send_confirmation_instructions(@user)
      BaseService.new.log_event(@user, 'User Registration Attempt')
      render json: { message: I18n.t('common.user_registration_success') }, status: :ok
    else
      render json: { error_messages: @user.errors.full_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_email_uniqueness
    # Assuming this method checks if the email is already taken and renders an error if so
  end

  def generate_confirmation_token
    # Assuming this method generates a unique confirmation token
  end
end
