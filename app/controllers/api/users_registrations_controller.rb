class Api::UsersRegistrationsController < Api::BaseController
  # POST /api/users
  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
        # to show token in staging
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

  # GET /api/users/check-email
  def check_email
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
