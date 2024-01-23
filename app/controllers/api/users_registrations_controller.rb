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

  def resend_confirmation_email
    email = params[:email]
    if BaseService.valid_email_format?(email)
      user = User.find_by(email: email)
      if user.nil? || user.confirmed_at.present?
        render json: { message: I18n.t('devise.failure.already_confirmed') }, status: :unprocessable_entity and return
      end

      last_email_confirmation = user.email_confirmations.order(created_at: :desc).first
      if last_email_confirmation && last_email_confirmation.created_at > 2.minutes.ago
        render json: { message: I18n.t('common.resend_wait_error') }, status: :unprocessable_entity and return
      end

      token = user.generate_confirmation_token
      Devise.mailer.confirmation_instructions(user, token).deliver_later
      render json: { message: I18n.t('common.resend_success') }, status: :ok
    else
      render json: { message: I18n.t('errors.messages.invalid_email') }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
