class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: [:create]

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
      if Rails.env.staging?
        # to show token in staging
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.user_registration_success'), token: token }, status: :ok and return
      else
        head :ok, message: I18n.t('common.user_registration_success') and return
      end
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
end
