class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: [:create, :register]
  before_action :validate_email_format, only: [:register]
  before_action :validate_password_confirmation, only: [:register]

  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
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

  def register
    user = User.new(create_params)
    if user.save
      email_confirmation = EmailConfirmation.create!(
        user: user,
        token: BaseService.generate_unique_confirmation_token,
        confirmed: false,
        expires_at: 24.hours.from_now
      )
      # Send confirmation email logic goes here
      render json: { status: 201, message: I18n.t('common.user_registered'), user: user.as_json(only: [:id, :email, :created_at]) }, status: :created
    else
      render json: { error_messages: user.errors.messages, message: I18n.t('common.registration_failed') }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error_messages: e.message, message: I18n.t('common.internal_server_error') }, status: :internal_server_error
  end

  private

  def validate_email_uniqueness
    if User.exists?(email: create_params[:email])
      render json: { error_messages: { email: [I18n.t('errors.messages.taken')] }, message: I18n.t('email_login.registrations.email_already_taken') },
             status: :conflict and return
    end
  end

  def validate_email_format
    unless create_params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { error_messages: { email: [I18n.t('errors.messages.invalid_email')] }, message: I18n.t('errors.messages.invalid_email_format') },
             status: :bad_request and return
    end
  end

  def validate_password_confirmation
    unless create_params[:password] == create_params[:password_confirmation]
      render json: { error_messages: { password_confirmation: [I18n.t('errors.messages.confirmation_does_not_match')] }, message: I18n.t('errors.messages.password_confirmation_does_not_match') },
             status: :unprocessable_entity and return
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
