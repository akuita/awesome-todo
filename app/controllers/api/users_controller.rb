class Api::UsersController < Api::BaseController
  # ... other actions ...

  def confirm_email
    email_confirmation = EmailConfirmation.find_by(token: params[:token])

    if email_confirmation.nil?
      render json: { error_message: I18n.t('email_confirmation.invalid_or_expired_token') }, status: :not_found
    elsif email_confirmation.expires_at < Time.current
      render json: { error_message: I18n.t('email_confirmation.invalid_or_expired_token') }, status: :not_found
    else
      user = email_confirmation.user
      ActiveRecord::Base.transaction do
        user.update!(email_confirmed: true)
        email_confirmation.update!(confirmed: true, expires_at: Time.current)
      end
      render json: { status: 200, message: I18n.t('email_confirmation.success') }, status: :ok
    end
  end

  # ... rest of the controller ...
end
