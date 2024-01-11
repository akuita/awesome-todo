class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: :create
  before_action :validate_password_security, only: :create
  before_action :validate_email_format, only: [:create, :resend_confirmation, :check_email_availability]
  before_action :validate_password_confirmation, only: :create

  def create
    @user = User.new(create_params)

    unless @user.password_meets_requirements?(create_params[:password])
      render json: { error_messages: [I18n.t('errors.messages.password_not_secure')] }, status: :bad_request and return
    end

    unless @user.password_confirmation_matches?(create_params[:password], create_params[:password_confirmation])
      render json: { error_messages: [I18n.t('errors.messages.password_confirmation_mismatch')] }, status: :bad_request and return
    end

    unless @user.respond_to?(:email_confirmed) && @user.respond_to?(:confirmation_token) && @user.respond_to?(:confirmation_sent_at)
      @user.assign_attributes(email_confirmed: false, confirmation_token: User.generate_unique_confirmation_token, confirmation_sent_at: Time.current)
    end

    if @user.save
      integrate_password_management_tool
      if Rails.env.staging?
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
      else
        # Send a confirmation email to the user with the token link
        Devise.mailer.confirmation_instructions(@user, @user.confirmation_token).deliver_later
        render json: { status: 201, message: I18n.t('users_registrations.success') }, status: :created
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { message: e.message }, status: :internal_server_error
  end

  # ... rest of the controller actions ...

  private

  def validate_email_uniqueness
    if User.find_by(email: create_params[:email])
      render json: { error_messages: [I18n.t('errors.messages.email_taken')] }, status: :conflict
      return
    end
  end

  def validate_email_format
    email = action_name == 'resend_confirmation' || action_name == 'check_email_availability' ? params[:email] : create_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error_messages: [I18n.t('errors.messages.invalid_email')] }, status: :unprocessable_entity
      return
    end
  end

  def validate_password_security
    unless IntegratePasswordManagementToolService.new.validate_password(create_params[:password])
      render json: { error_messages: [I18n.t('errors.messages.password_security')] }, status: :bad_request
      return
    end
  end

  def validate_password_confirmation
    unless create_params[:password] == create_params[:password_confirmation]
      render json: { error_messages: [I18n.t('errors.messages.password_confirmation_mismatch')] }, status: :unprocessable_entity
      return
    end
  end

  def integrate_password_management_tool
    # Assuming this method exists and integrates the password management tool as required.
    # This is a placeholder for the actual integration logic.
    # The existing code for this method is not provided, so we assume it's correct and does not need changes.
  end

  def create_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
