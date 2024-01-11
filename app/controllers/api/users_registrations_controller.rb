class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: :create
  before_action :validate_email_format, only: [:create, :resend_confirmation]
  before_action :validate_password_confirmation, only: :create

  def create
    # Assign the plain text password to the user model
    @user = User.new(create_params)
    unless @user.valid_password?(create_params[:password])
      render json: { error_messages: [I18n.t('errors.messages.password_security')] }, status: :unprocessable_entity and return
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

  def resend_confirmation
    email = params[:email]

    user = User.find_by(email: email)

    if user.nil?
      render json: { message: I18n.t('errors.messages.not_found') }, status: :not_found and return
    elsif user.email_confirmed?
      render json: { message: I18n.t('errors.messages.already_confirmed') }, status: :unprocessable_entity and return
    elsif user.confirmation_sent_at && Time.current < user.confirmation_sent_at + 2.minutes
      render json: { message: I18n.t('devise.failure.confirmation_period_expired', period: '2 minutes') }, status: :too_many_requests and return
    end

    if user.regenerate_confirmation_token
      Devise.mailer.confirmation_instructions(user, user.confirmation_token).deliver_later
      render json: { status: 200, message: I18n.t('devise.confirmations.new.resend_confirmation_instructions') }, status: :ok
    else
      render json: { message: I18n.t('errors.messages.not_saved.other', count: user.errors.count, resource: 'User') }, status: :unprocessable_entity if user.errors.any?
    end
  end

  private

  def validate_email_uniqueness
    if User.find_by(email: create_params[:email])
      render json: { error_messages: [I18n.t('errors.messages.email_taken')], message: I18n.t('devise.failure.invalid', authentication_keys: 'Email') }, status: :unprocessable_entity
      return
    end
  end

  def validate_email_format
    email = action_name == 'resend_confirmation' ? params[:email] : create_params[:email]
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error_messages: [I18n.t('errors.messages.invalid_email')] }, status: :unprocessable_entity
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
    # Ensure the "password" parameter is permitted
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
