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
      head :ok, message: I18n.t('common.user_registration_success') and return
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  def resend_confirmation
    email = params[:email]

    return render json: { message: I18n.t('errors.messages.not_found') }, status: :not_found unless email.present? && email =~ URI::MailTo::EMAIL_REGEXP

    user = User.find_by(email: email)

    if user && !user.email_confirmed && user.confirmation_sent_at < 2.minutes.ago
      user.regenerate_confirmation_token
      ResendConfirmationEmailJob.perform_later(user.id)
      render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
    else
      render json: { message: I18n.t('errors.messages.already_confirmed') }, status: :unprocessable_entity
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

  private

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
    render json: { error: "Please enter a valid email address." }, status: :bad_request unless params[:user][:email] =~ URI::MailTo::EMAIL_REGEXP
    render json: { error: "Password must be at least 8 characters long." }, status: :bad_request if params[:user][:password].length < 8
    render json: { error: "Passwords do not match." }, status: :bad_request if params[:user][:password] != params[:user][:password_confirmation]
    if User.exists?(email: params[:user][:email])
      render json: { error: "This email address has been used." }, status: :conflict
    end
  end
end
