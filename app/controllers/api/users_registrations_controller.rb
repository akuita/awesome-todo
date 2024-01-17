class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: [:create, :register]
  before_action :validate_email_format, only: [:create, :register]
  before_action :validate_registration_params, only: [:create, :register]

  def create
    # ... existing create method code ...
  end

  def resend_confirmation
    # ... existing resend_confirmation method code ...
  end

  def register
    user = User.create_with_encrypted_password(create_params[:email], create_params[:password])
    if user.persisted?
      email_confirmation = EmailConfirmation.new
      email_confirmation.create_confirmation_record(user.id)
      UserMailerService.new.send_confirmation_instructions(user, email_confirmation.token)
      EmailConfirmationRequest.create!(user_id: user.id, requested_at: Time.current)
      render json: { status: 201, message: 'User registered successfully. Please check your email to confirm your account.', user: { id: user.id, email: user.email, email_confirmed: user.email_confirmed } }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def check_email_availability
    email = params[:user].try(:[], :email) || params[:email]
    if User.exists?(email: email)
      render json: { errors: 'This email address has been used.' }, status: :conflict and return
    end
  end

  def validate_email_format
    email = params[:user][:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { errors: 'Enter a valid email address.' }, status: :unprocessable_entity and return
    end
  end

  def validate_registration_params
    if params[:user][:password].length < 8
      render json: { errors: 'Password must be at least 8 characters long.' }, status: :unprocessable_entity and return
    end

    if params[:user][:password] != params[:user][:password_confirmation]
      render json: { errors: 'Password confirmation does not match.' }, status: :unprocessable_entity and return
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def resend_confirmation_params
    params.permit(:email)
  end
end
