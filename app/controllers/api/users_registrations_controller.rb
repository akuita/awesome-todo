class Api::UsersRegistrationsController < Api::BaseController
  before_action :check_email_availability, only: :create
  before_action :validate_registration_params, only: [:create]

  def create
    email = params[:email]
    password_hash = params[:password_hash]

    begin
      user = BaseService.new.create_user_account(email: email, password_hash: password_hash)
      if user.persisted?
        EmailConfirmation.create_confirmation_record(user.id) # New code addition
        head :ok, message: I18n.t('common.200') and return
      end
    rescue => e
      logger.error "Failed to create user: #{e.message}"
      render json: { error_messages: [e.message], message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity and return
    end

    @user = User.new(create_params)
    if @user.save
      EmailConfirmation.create_confirmation_record(@user.id) # Ensure this line is present only once
      head :ok, message: I18n.t('common.200') and return
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
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
end
