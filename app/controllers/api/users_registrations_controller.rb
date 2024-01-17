class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create
  skip_before_action :check_email_availability, only: :check_email_availability
  before_action :validate_registration_params, only: [:create, :register]

  def create
    # ... existing create action code ...
  end

  def resend_confirmation
    email = resend_confirmation_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      return render json: { message: "Please enter a valid email address." }, status: :bad_request
    end

    user = User.find_by(email: email, email_confirmed: false)
    if user.nil?
      return render json: { message: "No account found with this email address." }, status: :not_found
    end

    email_confirmation = user.email_confirmations.where(confirmed: false).first_or_initialize
    if email_confirmation.new_record? || email_confirmation.updated_at < 2.minutes.ago
      email_confirmation.generate_token
      email_confirmation.save!
      UserMailerService.new.send_confirmation_instructions(user, email_confirmation.token)
      render json: { status: 200, message: "Confirmation email resent successfully. Please check your inbox." }, status: :ok
    else
      render json: { message: "You can request a new confirmation link every 2 minutes." }, status: :too_many_requests
    end
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

# GET /api/users/check_email_availability
def check_email_availability
  email = params[:email]
  email_taken = User.exists?(email: email)
  render json: { available: !email_taken }
rescue StandardError => e
  render json: { error: e.message }, status: :internal_server_error
end

end
