class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create
  before_action :validate_email_format, only: [:create, :register]
  before_action :validate_registration_params, only: [:create, :register]

  def create
    # ... existing create action code ...
  end

  def resend_confirmation
    email = resend_confirmation_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      return render json: { message: "Please enter a valid email address." }, status: :bad_request
    end

    user = User.find_by(email: email, email_confirmed: false) || User.unconfirmed_with_email(email).first
    if user.nil?
      return render json: { message: "No account found with this email address." }, status: :not_found
    end

    email_confirmation = user.email_confirmations.where(confirmed: false).order(created_at: :desc).first_or_initialize
    if email_confirmation.new_record? || email_confirmation.created_at < 2.minutes.ago
      email_confirmation.token ||= SecureRandom.hex(10)
      email_confirmation.expires_at ||= 24.hours.from_now
      email_confirmation.save!
      UserMailerService.new.send_confirmation_instructions(user, email_confirmation.token)
      render json: { message: "Confirmation email resent successfully. Please check your inbox." }, status: :ok
    else
      render json: { message: "You can request a new confirmation link every 2 minutes." }, status: :too_many_requests
      email_confirmation.log_request(user.id, Time.current) if email_confirmation.respond_to?(:log_request)
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

  def validate_email_format
    email = params[:user][:email]
    validator = EmailFormatValidator.new(attributes: [:email])
    dummy_record = OpenStruct.new(email: email)
    validator.validate_each(dummy_record, :email, email)
    if dummy_record.errors.any?
      render json: { message: I18n.t('common.invalid_email_format') }, status: :unprocessable_entity and return
    end
  end

  private

  def check_email_availability
    email = params[:user].try(:[], :email) || params[:email]
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
