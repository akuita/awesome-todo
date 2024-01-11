
class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_format, only: [:create]
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
        render json: { status: 201, message: I18n.t('common.user_registered') }, status: :created and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  rescue => e
    render json: { message: I18n.t('common.500'), error: e.message }, status: :internal_server_error
  end

  def resend_confirmation
    email_param = params[:email]
    if email_param.blank? || !(email_param =~ URI::MailTo::EMAIL_REGEXP)
      render json: { message: I18n.t('email_login.registrations.invalid_email_format') }, status: :unprocessable_entity and return
    end

    user = User.find_by(email: email_param)
    if user.nil?
      render json: { message: I18n.t('email_login.registrations.email_not_found') }, status: :not_found and return
    end

    if defined?(EmailConfirmation)
      token = user.generate_confirmation_token
      if token
        EmailConfirmation.send_confirmation_email(user) # Assuming this method exists and sends the email
        render json: { status: 200, message: I18n.t('email_login.registrations.confirmation_email_resent') }, status: :ok
      else
        render json: { message: I18n.t('email_login.registrations.failed_to_resent_confirmation_email') }, status: :unprocessable_entity
      end
    else
      render json: { message: I18n.t('email_login.registrations.email_confirmation_not_defined') }, status: :unprocessable_entity
    end
  end

  def check_email_availability
    email_param = params[:email]
    if email_param.blank? || !(email_param =~ URI::MailTo::EMAIL_REGEXP)
      render json: { message: I18n.t('email_login.registrations.invalid_email_format') }, status: :bad_request and return
    end

    email_available = User.email_available?(email_param)
    render json: { available: email_available }, status: :ok
  rescue => e
    render json: { message: I18n.t('common.500'), error: e.message }, status: :internal_server_error
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_email_format
    unless create_params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { message: I18n.t('email_login.registrations.invalid_email_format') },
             status: :bad_request and return
    end
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
    unless create_params[:password] == create_params[:password_confirmation]
      render json: { message: I18n.t('email_login.registrations.password_confirmation_mismatch') },
             status: :bad_request and return
    end
    if User.email_registered?(create_params[:email])
      render json: { message: I18n.t('email_login.registrations.email_already_registered') },
             status: :conflict and return
    end
  end
end
