class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_registration_params, only: :register

  # POST /api/users
  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
      else
        head :ok, message: I18n.t('common.200') and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  # POST /api/users/register
  def register
    @user = User.new(create_params)
    if @user.save
      render json: { status: 201, message: I18n.t('devise.registrations.signed_up') }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # POST /api/users/resend-confirmation
  def resend_confirmation
    email = params[:email]
    if email.blank?
      render json: { error: "Please enter a valid email address." }, status: :bad_request and return
    elsif !(email =~ URI::MailTo::EMAIL_REGEXP)
      render json: { error: "Please enter a valid email address." }, status: :bad_request and return
    end

    user = User.find_by(email: email)
    if user.nil?
      render json: { error: "Email address not found." }, status: :not_found and return
    elsif user.confirmation_sent_at && user.confirmation_sent_at > 2.minutes.ago
      render json: { error: "You can request to resend the confirmation link every 2 minutes." }, status: :too_many_requests and return
    else
      user.send_confirmation_instructions
      render json: { status: 200, message: "Confirmation email resent successfully. Please check your inbox." }, status: :ok
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /api/users/check-email
  def check_email_availability
    email = params[:email]
    if email.blank?
      render json: { error: I18n.t('activerecord.errors.messages.blank') }, status: :unprocessable_entity and return
    elsif !(email =~ URI::MailTo::EMAIL_REGEXP)
      render json: { error: I18n.t('activerecord.errors.messages.invalid') }, status: :unprocessable_entity and return
    end

    email_available = !User.email_exists?(email)
    render json: { available: email_available }, status: :ok
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_registration_params
    email = params[:user][:email]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]

    if email.blank?
      render json: { error: I18n.t('activerecord.errors.messages.blank') }, status: :unprocessable_entity and return
    elsif !(email =~ URI::MailTo::EMAIL_REGEXP)
      render json: { error: "Please enter a valid email address." }, status: :unprocessable_entity and return
    elsif User.email_exists?(email)
      render json: { error: "This email address has already been used." }, status: :unprocessable_entity and return
    elsif password != password_confirmation
      render json: { error: "Passwords do not match." }, status: :unprocessable_entity and return
    elsif password.length < 8
      render json: { error: "Password must be at least 8 characters long." }, status: :unprocessable_entity and return
    end
  end
end
