class Api::UsersResetPasswordRequestsController < Api::BaseController
  def create
    unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Enter a valid email address." }, status: :unprocessable_entity
      return
    end

    @user = User.find_by('email = ?', params.dig(:email))
    @user.send_reset_password_instructions if @user.present?
    head :ok, message: I18n.t('common.200')
  end
end
