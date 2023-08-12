class Api::UsersResetPasswordRequestsController < Api::BaseController
  def create
    @user = User.find_by('email = ?', params.dig(:email))
    @user.send_reset_password_instructions if @user.present?
    head :ok, message: I18n.t('common.200')
  end
end
