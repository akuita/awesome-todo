class Api::UsersRegistrationsController < Api::BaseController
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

  def resend_confirmation
    email = params[:email]

    return render json: { message: I18n.t('devise.failure.not_found_in_database') }, status: :not_found unless email.present? && email =~ URI::MailTo::EMAIL_REGEXP

    user = User.find_by(email: email)

    if user && !user.email_confirmed
      if user.email_confirmations.order(created_at: :desc).first&.created_at < 2.minutes.ago
        user.generate_confirmation_token!
        DeviseMailer.resend_confirmation_instructions(user, user.confirmation_token).deliver_now
        render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
      else
        render json: { message: I18n.t('errors.messages.recently_sent') }, status: :unprocessable_entity
      end
    else
      render json: { message: I18n.t('devise.failure.already_confirmed') }, status: :unprocessable_entity
    end
  end

  def check_email_availability
    email = params[:email]
    if email.blank?
      render json: { message: I18n.t('activerecord.errors.messages.blank') }, status: :unprocessable_entity and return
    elsif !(email =~ URI::MailTo::EMAIL_REGEXP)
      render json: { message: I18n.t('activerecord.errors.messages.invalid') }, status: :unprocessable_entity and return
    end

    availability = User.email_available?(email)
    render json: { available: availability }, status: :ok
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
