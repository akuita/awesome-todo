class Api::UsersRegistrationsController < Api::BaseController
  # POST /api/users/resend-confirmation
  def resend_confirmation
    email = params[:email]

    unless BaseService.valid_email_format?(email)
      render json: { message: I18n.t('errors.messages.invalid_email') }, status: :bad_request and return
    end

    user = User.find_by(email: email)
    if user.nil?
      render json: { message: I18n.t('devise.failure.not_found_in_database') }, status: :not_found and return
    elsif user.confirmed_at.present?
      render json: { message: I18n.t('devise.failure.already_confirmed') }, status: :unprocessable_entity and return
    end

    last_email_confirmation = user.email_confirmations.order(created_at: :desc).first
    if last_email_confirmation && last_email_confirmation.created_at > 2.minutes.ago
      render json: { message: I18n.t('common.resend_wait_error') }, status: :too_many_requests and return
    end

    token = user.generate_confirmation_token
    Devise.mailer.confirmation_instructions(user, token).deliver_later
    render json: { status: 200, message: I18n.t('common.resend_success') }, status: :ok
  end

  # Other controller actions (create, etc) remain unchanged
  # ...

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
