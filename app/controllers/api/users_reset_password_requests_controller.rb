
class Api::UsersResetPasswordRequestsController < Api::BaseController
  def create
    email = params.dig(:email)
    unless validate_email_format(email)
      render json: { message: I18n.t('errors.messages.invalid_email') }, status: :unprocessable_entity and return
    end

    @user = User.find_by('email = ?', email)
    @user.send_reset_password_instructions if @user.present?
    head :ok, message: I18n.t('common.200')
  end

  private

  def validate_email_format(email)
    email.to_s.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end
end
