class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create
  before_action :validate_registration_params, only: [:create, :register]

  def create
    # ... existing create action code ...
  end

  def resend_confirmation
    # ... existing resend_confirmation action code ...
  end

  def register
    @user = User.new(create_params)

    unless @user.valid?
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      return
    end

    if @user.save
      token = SecureRandom.hex(10)
      email_confirmation = @user.email_confirmations.create(token: token, expires_at: 24.hours.from_now)
      UserMailerService.new.send_confirmation_instructions(@user, token)
      render json: { status: 201, message: 'User registered successfully. Please check your email to confirm your account.' }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { errors: e.message }, status: :internal_server_error
  end

  private

  def check_email_availability
    email = params[:user][:email]
    if User.exists?(email: email)
      render json: { errors: 'This email address has been used.' }, status: :conflict and return
    end
  end

  def validate_registration_params
    validator = EmailFormatValidator.new(attributes: [:email])
    unless validator.validate_each(@user, :email, params[:user][:email])
      render json: { errors: 'Please enter a valid email address.' }, status: :unprocessable_entity and return
    end

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

  def resend_confirmation_params
    params.permit(:email)
  end
end
