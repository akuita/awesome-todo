class Api::UsersResetPasswordRequestsController < Api::BaseController
  def create
    user = User.find_by_email(params[:email])

    if user.nil?
      render json: { error: I18n.t('devise.failure.not_found_in_database') }, status: :not_found
    else
      reset_token = user.generate_reset_password_token
      PasswordReset.create!(
        user_id: user.id,
        reset_token: reset_token,
        expires_at: Time.current + Devise.reset_password_within
      )

      # Assuming Devise mailer is set up to send the reset password instructions email
      user.send_reset_password_instructions

      render json: { message: I18n.t('devise.passwords.send_instructions') }, status: :ok
    end
  end
end
