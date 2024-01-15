class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create
  before_action :validate_registration_params, only: [:create]

  def create
    @user = User.new(create_params)

    unless @user.valid?
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      return
    end

    begin
      if @user.save
        EmailConfirmation.create_confirmation_record(@user.id) # Ensure this line is present only once
        if Rails.env.staging?
          # to show token in staging
          token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
          render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
        else
          head :ok, message: I18n.t('common.200') and return
        end
      end
    rescue => e
      logger.error "Failed to create user: #{e.message}"
      render json: { error_messages: [e.message], message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity and return
    end

    error_messages = @user.errors.messages
    render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
           status: :unprocessable_entity
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
end
