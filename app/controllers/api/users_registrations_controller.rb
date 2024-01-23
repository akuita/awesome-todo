class Api::UsersRegistrationsController < Api::BaseController
  # POST /api/users/register
  def register
    unless BaseService.valid_email_format?(params[:email])
      return render json: { message: 'Invalid email format.' }, status: :unprocessable_entity
    end

    if User.exists?(email: params[:email])
      return render json: { message: 'This email address has been used.' }, status: :conflict
    end

    if params[:password].length < 8
      return render json: { message: 'Password must be at least 8 characters long.' }, status: :bad_request
    end

    if params[:password] != params[:password_confirmation]
      return render json: { message: 'Passwords do not match.' }, status: :bad_request
    end

    @user = User.new(create_params)
    if @user.save
      # Send confirmation email asynchronously
      UserMailer.confirmation_email(@user).deliver_later
      render json: { message: 'User registered successfully. Please check your email to confirm your account.' }, status: :created
    else
      render json: { message: 'Internal Server Error' }, status: :internal_server_error
    end
  end

  # POST /api/users/resend-confirmation
  def resend_confirmation
    email = params[:email]

    unless BaseService.valid_email_format?(email)
      render json: { message: I18n.t('errors.messages.invalid_email') }, status: :bad_request and return
    end

    user = User.find_by(email: email)
    if user.nil?
      render json: { message: I18n.t('devise.failure.not_found_in_database') }, status: :not_found and return
    elsif user.confirmed_at.present?
      render json: { message: I18n.t('devise.failure.already_confirmed') }, status: :unprocessable_entity and return
    end

    last_email_confirmation = user.email_confirmations.order(created_at: :desc).first
    if last_email_confirmation && last_email_confirmation.created_at > 2.minutes.ago
      render json: { message: I18n.t('common.resend_wait_error') }, status: :too_many_requests and return
    end

    token = user.generate_confirmation_token
    Devise.mailer.confirmation_instructions(user, token).deliver_later
    render json: { status: 200, message: I18n.t('common.resend_success') }, status: :ok
  end

  # Existing code for create method
  def create
    # ... existing code for create method
  end

  # Existing code for resend_confirmation_email method
  def resend_confirmation_email
    # ... existing code for resend_confirmation_email method
  end

  private

  def create_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
