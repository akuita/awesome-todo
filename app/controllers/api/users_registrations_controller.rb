class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_format, only: [:create, :check_email_availability]
  before_action :validate_password_confirmation, only: [:create]
  before_action :validate_password_strength, only: [:create]
  before_action :validate_password_complexity, only: [:create]

  def create
    if User.email_registered?(create_params[:email])
      render json: { error: 'This email address has been used.' }, status: :conflict
    else
      @user = User.new(create_params)
      if @user.save
        render json: {
          status: 201,
          message: 'User registered successfully. Please check your email to confirm your account.',
          user: {
            id: @user.id,
            email: @user.email,
            email_confirmed: @user.email_confirmed?,
            created_at: @user.created_at.iso8601
          }
        }, status: :created
        # Send confirmation email logic should be here
        # Assuming EmailConfirmation module and DeviseMailer are available and properly configured
        if defined?(EmailConfirmation)
          token = @user.generate_confirmation_token
          DeviseMailer.confirmation_instructions(@user, token).deliver_later if token
        end
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def check_email_availability
    email = params[:email]
    if User.email_available?(email)
      render json: { status: 200, available: true }, status: :ok
    else
      render json: { status: 409, available: false }, status: :conflict
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def validate_email_format
    email = params[:email] || create_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: 'Invalid email format.' }, status: :bad_request and return false
    end
    true
  end

  def validate_password_strength
    unless create_params[:password].length >= 8
      render json: { message: 'Password must be at least 8 characters long.' },
             status: :unprocessable_entity and return
    end
    unless User::PASSWORD_FORMAT.match?(create_params[:password])
      render json: { message: I18n.t('email_login.registrations.weak_password') },
             status: :unprocessable_entity and return
    end
  end

  def validate_password_confirmation
    unless create_params[:password] == create_params[:password_confirmation]
      render json: { message: 'Passwords do not match.' },
             status: :bad_request and return
    end
  end

  def validate_password_complexity
    # Assuming User model has a method 'password_complexity_compatible?' to check the complexity
    # If the method does not exist, this will need to be implemented in the User model.
    unless @user.password_complexity_compatible?
      render json: { message: 'Password does not meet complexity requirements.' },
             status: :unprocessable_entity and return
    end
  end
end
