class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_format, only: :create
  before_action :validate_email_uniqueness, only: [:create]

  def create
    return unless validate_email_format
    
    @user = User.new(create_params.merge(email_confirmed: false))
    if @user.save
      token = generate_email_confirmation_token(@user)
      EmailConfirmationToken.create!(user: @user, token: token, created_at: Time.now, updated_at: nil)
      ApplicationJob.perform_later(@user.id)
      
      if Rails.env.staging?
        # to show token in staging
        render json: { message: I18n.t('common.200'), token: token }, status: :ok
      else
        render json: { message: I18n.t('devise.registrations.signed_up_but_unconfirmed') }, status: :ok
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  private

  def validate_email_format
    email = params[:user][:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: I18n.t('activerecord.errors.messages.invalid_email_format') }, status: :unprocessable_entity
      return false
    end
    true
  end

  def validate_email_uniqueness
    if User.exists?(email: params[:user][:email])
      render json: { message: I18n.t('errors.messages.taken') }, status: :unprocessable_entity
      return false
    end
    true
  end

  def generate_email_confirmation_token(user)
    loop do
      token = SecureRandom.hex(10)
      break token unless EmailConfirmation.exists?(token: token)
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
