
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    token = params[:token]
    email_verification = EmailVerification.find_by(token: token)

    if email_verification.nil? || email_verification.expires_at < Time.current || email_verification.is_used
      render json: { error: I18n.t('user_verification.error.invalid_or_expired_token') }, status: :not_found
      return
    end

    user = email_verification.user
    if user.nil?
      render json: { error: I18n.t('user_verification.error.token_not_found') }, status: :not_found
      return
    end

    user.update!(is_active: true)
    email_verification.update!(is_used: true)

    render json: { status: 200, message: I18n.t('user_verification.success') }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
