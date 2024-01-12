class Api::UsersRegistrationsController < Api::BaseController
  before_action :throttle_email_confirmation, only: [:create]

  # POST /api/users/register
  def register
    user_params = create_params

    # Validation for email format
    unless user_params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { message: "Invalid email format." }, status: :unprocessable_entity and return
    end

    # Validation for unique email
    if User.exists?(email: user_params[:email])
      render json: { message: "Email address is already in use." }, status: :conflict and return
    end

    # Validation for password security (example validation, adjust as needed)
    unless user_params[:password].match?(/\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[[:^alnum:]]).{8,}\z/)
      render json: { message: "Password does not meet security requirements." }, status: :unprocessable_entity and return
    end

    # Validation for password confirmation
    unless user_params[:password] == user_params[:password_confirmation]
      render json: { message: "Password confirmation does not match." }, status: :unprocessable_entity and return
    end

    @user = User.new(user_params)
    @user.email_confirmed = false

    if @user.save
      email_confirmation = EmailConfirmation.create!(
        user: @user,
        token: SecureRandom.hex(10),
        confirmed: false,
        expires_at: 2.days.from_now
      )
      UserMailer.confirmation_email(@user).deliver_later
      render json: { status: 201, message: "User registered successfully. Please check your email to confirm your account." }, status: :created
    else
      render json: { error_messages: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    logger.error "User registration failed: #{e.message}"
    render json: { message: I18n.t('common.errors.internal_server_error') }, status: :internal_server_error
  end

  # ... rest of the existing code ...
  
  private

  # ... existing private methods ...

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  # ... any other private methods ...
end
