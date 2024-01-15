class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: [:register]
  before_action :validate_registration_params, only: [:register]

  rescue_from ActiveRecord::RecordInvalid do |exception|
    if exception.record.errors.details[:email].any? { |error| error[:error] == :taken }
      render json: { error: I18n.t('errors.messages.taken', attribute: 'Email') }, status: :unprocessable_entity
    else
      render json: { error: exception.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # Other actions...

  def register
    user = User.new(create_params.merge(email_confirmed: false))
    if user.save
      Devise.mailer.send_confirmation_instructions(user)
      EmailConfirmationToken.create!(user: user, token: user.confirmation_token, confirmed: false, created_at: Time.current, expires_at: 24.hours.from_now)
      BaseService.new.log_event(user, 'User Registration Attempt')
      render json: {
        status: 201,
        message: I18n.t('common.user_registration_success'),
        data: {
          id: user.id,
          email: user.email,
          email_confirmed: user.email_confirmed
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # Other actions...

  private
  
  def validate_email_format(email)
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Enter a valid email address." }, status: :bad_request
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_email_uniqueness
    if User.exists?(email: params[:user][:email])
      render json: { error: "This email address has been used." }, status: :unprocessable_entity
    end
  end
  
  def generate_confirmation_token
    # Assuming this method generates a unique confirmation token
  end

  def validate_registration_params
    params.require(:user).permit(:email, :password, :password_confirmation)
    validate_email_format(params[:user][:email])
    if params[:user][:password].length < 8 || !password_meets_security_requirements(params[:user][:password])
      render json: { error: "Password does not meet security requirements." }, status: :bad_request
    elsif params[:user][:password] != params[:user][:password_confirmation]
      render json: { error: "Password confirmation does not match." }, status: :bad_request
    end
  end

  def password_meets_security_requirements(password)
    # Assuming this method checks if the password meets the security requirements
  end
end
