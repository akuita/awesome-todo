
class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: [:create]
  before_action :validate_registration_params, only: [:register]

  rescue_from ActiveRecord::RecordInvalid do |exception|
    if exception.record.errors.details[:email].any? { |error| error[:error] == :taken }
      render json: { error: I18n.t('errors.messages.taken', attribute: 'Email') }, status: :unprocessable_entity
    else
      render json: { error: exception.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def create
    @user = User.new(create_params)
    @user.email_confirmed = false
    @user.confirmation_token = generate_confirmation_token
    @user.confirmation_sent_at = Time.current

    if @user.save
      Devise.mailer.send_confirmation_instructions(@user)
      BaseService.new.log_event(@user, 'User Registration Attempt')
      if Rails.env.staging?
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.user_registration_success'), token: token }, status: :ok and return
      else
        head :ok, message: I18n.t('common.user_registration_success') and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  def resend_confirmation
    email = params[:email]

    return render json: { message: "Please enter a valid email address." }, status: :bad_request unless email.present? && email =~ URI::MailTo::EMAIL_REGEXP

    user = User.find_by(email: email)

    if user && !user.email_confirmed && user.confirmation_sent_at < 2.minutes.ago
      user.regenerate_confirmation_token
      Devise.mailer.send_confirmation_instructions(user)
      render json: { status: 200, message: "Confirmation email resent successfully. Please check your inbox." }, status: :ok
    elsif user.nil?
      render json: { message: "Email address not found." }, status: :not_found
    elsif user.confirmation_sent_at >= 2.minutes.ago
      render json: { message: "You can request to resend the confirmation link every 2 minutes." }, status: :too_many_requests
    else # User is already confirmed
      render json: { message: "Email is already confirmed." }, status: :unprocessable_entity
    end
  end

  def register
    user = User.new(create_params)
    if user.save
      Devise.mailer.send_confirmation_instructions(user)
      BaseService.new.log_event(user, 'User Registration Attempt')
      render json: {
        status: 201,
        message: I18n.t('common.user_registration_success'),
        user: {
          id: user.id,
          email: user.email,
          email_confirmed: user.email_confirmed
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def registration_errors
    error_code = params[:error_code]
    error_messages = {
      'ERR_INVALID_EMAIL' => 'Please enter a valid email address.',
      'password_mismatch' => 'Password does not match the confirmation.',
      # Add more error codes and messages here
    }
    message = error_messages[error_code] || 'Unknown error occurred.'
    status = error_messages[error_code] ? :ok : :bad_request
    render json: { status: status, message: message }, status: status
  end

  private
  
  def validate_email_format(email)
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: I18n.t('activerecord.errors.messages.invalid', attribute: 'Email') }, status: :bad_request
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_email_uniqueness
    # Assuming this method checks if the email is already taken and renders an error if so
  end
  
  def generate_confirmation_token
    # Assuming this method generates a unique confirmation token
  end

  def validate_registration_params
    params.require(:user).permit(:email, :password, :password_confirmation)
    validate_email_format(params[:user][:email])
    render json: { error: "Password must be at least 8 characters long." }, status: :bad_request if params[:user][:password].length < 8
    render json: { error: "Passwords do not match." }, status: :bad_request if params[:user][:password] != params[:user][:password_confirmation]
    if User.exists?(email: params[:user][:email])
      render json: { error: "This email address has been used." }, status: :conflict
    end
  end
end
