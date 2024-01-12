class Api::UsersRegistrationsController < Api::BaseController
  before_action :throttle_email_confirmation, only: [:create]

  def create
    user_params = create_params

    # Validation for email format
    unless user_params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { message: "Invalid email format." }, status: :unprocessable_entity and return
    end

    existing_user = User.find_by(email: user_params[:email])

    # Validation for unique email
    if existing_user
      render json: { message: I18n.t('email_login.registrations.email_already_in_use') }, status: :unprocessable_entity and return
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

      if Rails.env.staging?
        token = email_confirmation.token
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
      else
        render json: { status: 201, message: "User registered successfully. Please check your email to confirm your account." }, status: :created
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  rescue StandardError => e
    logger.error "User registration failed: #{e.message}"
    render json: { message: I18n.t('common.errors.internal_server_error') }, status: :internal_server_error
  end

  def resend_confirmation_email
    email = resend_confirmation_params[:email]
    user = User.find_by(email: email)

    if user.nil? || user.email_confirmed
      message = user.nil? ? I18n.t('email_login.registrations.email_not_found') : I18n.t('email_login.registrations.email_already_confirmed')
      render json: { message: message }, status: :not_found
    else
      email_confirmation = user.email_confirmations.order(created_at: :desc).first
      if email_confirmation && email_confirmation.created_at > 2.minutes.ago
        remaining_time = (2.minutes.since(email_confirmation.created_at) - Time.current).round
        render json: { message: I18n.t('email_login.registrations.wait_time', time: remaining_time) }, status: :too_many_requests
      else
        token = user.generate_confirmation_token
        email_confirmation.update(token: token, created_at: Time.current)
        UserMailer.confirmation_email(user, token).deliver_now
        render json: { status: 200, message: I18n.t('email_login.registrations.confirmation_resent') }, status: :ok
      end
    end
  rescue StandardError => e
    render json: { message: e.message }, status: :internal_server_error
  end

  private

  def throttle_email_confirmation
    return unless @user

    last_email_confirmation = EmailConfirmation.where(user_id: @user.id).order(created_at: :desc).first
    if last_email_confirmation && last_email_confirmation.created_at > 2.minutes.ago
      render json: { message: I18n.t('email_login.registrations.throttle_email_confirmation') }, status: :too_many_requests and return
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def resend_confirmation_params
    params.require(:user).permit(:email)
  end
end
