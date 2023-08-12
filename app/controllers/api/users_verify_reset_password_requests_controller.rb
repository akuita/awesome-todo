class Api::UsersVerifyResetPasswordRequestsController < Api::BaseController
  def create
    token = Devise.token_generator.digest(User, :reset_password_token, params.dig(:reset_token))

    @user = User.find_by(reset_password_token: token)

    if @user.blank? || params.dig(:reset_token).blank? || params.dig(:password).blank? || params.dig(:password_confirmation).blank?
      @error_message = I18n.t('reset_password.invalid_token')
    elsif !@user.reset_password_period_valid?
      @error_message = I18n.t('errors.messages.expired')
    elsif @user.reset_password(params.dig(:password), params.dig(:password), params.dig(:password_confirmation))
    else
      @error_message = @user.errors.full_messages
    end
    if @error_message.present?
      render json: { error_message: @error_message }, status: :unprocessable_entity
    else
      head :ok, message: I18n.t('common.200')
    end
  end
end
