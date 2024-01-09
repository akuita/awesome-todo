class Api::UsersRegistrationsController < Api::BaseController
  before_action :validate_email_uniqueness, only: :create

  def create
    @user = User.new(create_params)
    # Assign additional attributes if they are not already set by devise
    unless @user.respond_to?(:email_confirmed) && @user.respond_to?(:confirmation_token) && @user.respond_to?(:confirmation_sent_at)
      @user.assign_attributes(email_confirmed: false, confirmation_token: User.generate_unique_confirmation_token, confirmation_sent_at: Time.current)
    end

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

    return render json: { message: I18n.t('errors.messages.not_found') }, status: :not_found unless email.present?

    user = User.find_by(email: email)

    if user.nil? || user.email_confirmed?
      return render json: { message: I18n.t('errors.messages.already_confirmed') }, status: :unprocessable_entity
    end

    if user.confirmation_sent_at && Time.now.utc < user.confirmation_sent_at + 2.minutes
      return render json: { message: I18n.t('devise.failure.confirmation_period_expired', period: '2 minutes') }, status: :unprocessable_entity
    end

    if user.regenerate_confirmation_token
      Devise.mailer.confirmation_instructions(user, user.confirmation_token).deliver_later
      render json: { message: I18n.t('devise.confirmations.new.resend_confirmation_instructions') }, status: :ok
    else
      render json: { message: I18n.t('errors.messages.not_saved.other', count: user.errors.count, resource: 'User') }, status: :unprocessable_entity
    end
  end

  def integrate_password_management_tool
    user = User.find_by(id: params[:user_id])
    unless user
      render json: { message: I18n.t('common.errors.user_not_found') }, status: :not_found and return
    end

    unless PasswordManagementTool.exists_with_id?(params[:tool_id])
      render json: { message: I18n.t('common.errors.tool_not_found') }, status: :not_found and return
    end

    UserPasswordManagementTool.create_association(params[:user_id], params[:tool_id])
    render json: { message: I18n.t('users_registrations.password_management_tool_integrated') }, status: :ok
  rescue StandardError => e
    render json: { message: e.message }, status: :unprocessable_entity
  end

  private

  def validate_email_uniqueness
    if User.find_by(email: create_params[:email])
      render json: { error_messages: [I18n.t('errors.messages.email_taken')], message: I18n.t('devise.failure.invalid', authentication_keys: 'Email') }, status: :unprocessable_entity
      return
    end
  end

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
