class Api::UsersRegistrationsController < Api::BaseController
  # POST /api/users
  def create
    @user = User.new(create_params)
    if @user.save
      head :ok, message: I18n.t('common.200') and return
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
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
      render json: { error: I18n.t('activerecord.errors.messages.blank') }, status: :bad_request and return
    elsif !(email =~ URI::MailTo::EMAIL_REGEXP)
      render json: { error: "Please enter a valid email address." }, status: :unprocessable_entity and return
    end

    if User.email_exists?(email)
      render json: { message: 'Email is not available' }, status: :conflict
    else
      render json: { status: 200, available: true }, status: :ok
    end
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
