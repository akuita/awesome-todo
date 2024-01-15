class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_format, only: [:create, :register]
  before_action :validate_email_uniqueness, only: [:create, :register]
  before_action :validate_password_confirmation, only: :register
  before_action :validate_password_security, only: :register

  def create
    return unless validate_email_format
    
    @user = User.new(create_params.merge(email_confirmed: false))
    if @user.save
      token = generate_email_confirmation_token(@user)
      EmailConfirmationToken.create!(user: @user, token: token, created_at: Time.now, updated_at: nil)
      ApplicationJob.perform_later(@user.id)
      
      if Rails.env.staging?
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

  def register
    @user = User.new(create_params.merge(email_confirmed: false))

    if @user.save
      token = generate_email_confirmation_token(@user)
      EmailConfirmationToken.create!(user: @user, token: token, created_at: Time.now, updated_at: nil)
      ApplicationJob.perform_later(@user.id)
      render json: { status: 201, message: I18n.t('devise.registrations.signed_up') }, status: :created
    else
      render json: { errors: @user.errors.full_messages, message: I18n.t('errors.messages.not_saved', count: @user.errors.count, resource: 'User') }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message, message: I18n.t('common.500') }, status: :internal_server_error
  end

  private

  def validate_email_format
    email = params[:user][:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Enter a valid email address." }, status: :unprocessable_entity
      return false
    end
    true
  end

  def validate_email_uniqueness
    if User.exists?(email: params[:user][:email])
      render json: { error: "This email address has already been used." }, status: :unprocessable_entity
      return false
    end
    true
  end

  def validate_password_confirmation
    unless params[:user][:password] == params[:user][:password_confirmation]
      render json: { error: "Password confirmation does not match." }, status: :unprocessable_entity
      return false
    end
    true
  end

  def validate_password_security
    # Assuming there is a method to validate password security requirements
    unless password_meets_security_requirements?(params[:user][:password])
      render json: { error: "Password does not meet security requirements." }, status: :unprocessable_entity
      return false
    end
    true
  end

  def password_meets_security_requirements?(password)
    # Implement password security check logic here
    # For example, a password might need to include at least one number, one lowercase letter, one uppercase letter, and be at least 8 characters long
    # This is a placeholder implementation
    password.length >= 8 && password.match?(/\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*\z/)
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
