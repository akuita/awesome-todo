class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create
  before_action :validate_registration_params, only: [:create]

  def create
    @user = User.new(create_params)

    unless @user.valid?
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      return
    end

    if @user.save
      EmailConfirmation.create_confirmation_record(@user.id) # Ensure this line is present only once
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
    return render json: { message: I18n.t('errors.messages.invalid') }, status: :unprocessable_entity unless email =~ URI::MailTo::EMAIL_REGEXP

    user = User.find_by(email: email, email_confirmed: false)
    if user.nil?
      return render json: { message: I18n.t('errors.messages.not_found') }, status: :not_found
    end

    email_confirmation = user.email_confirmations.where(confirmed: false).first_or_initialize
    if email_confirmation.new_record? || email_confirmation.updated_at < 2.minutes.ago
      email_confirmation.generate_confirmation_token!
      email_confirmation.save!
      UserMailerService.send_confirmation_instructions(user, email_confirmation.token)
      render json: { message: I18n.t('devise.confirmations.send_instructions') }, status: :ok
    else
      render json: { message: I18n.t('errors.messages.too_short', count: '2 minutes') }, status: :unprocessable_entity
    end
  end

  private

  def check_email_availability
    email = params[:user][:email]
    if User.exists?(email: email)
      render json: { message: I18n.t('common.422'), error: 'Email is already taken' }, status: :unprocessable_entity and return
    end
  end

  def validate_registration_params
    # The original code for validation should be here, but since the patch does not provide it,
    # we assume it's a placeholder for actual validation logic.
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def resend_confirmation_params
    params.permit(:email)
  end
end
