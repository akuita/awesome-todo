class Api::UsersController < ApplicationController
  before_action :load_user_by_confirmation_token, only: :confirm_email

  def confirm_email
    if @user.confirmation_token_expired?
      render json: { error_message: I18n.t('errors.messages.confirmation_token.expired') }, status: :unprocessable_entity
    else
      begin
        result = EmailConfirmationService.new(@user.confirmation_token).confirm_email
        render json: { status: 200, message: I18n.t('devise.confirmations.confirmed') }, status: :ok
      rescue StandardError => e
        render json: { error_message: e.message }, status: :internal_server_error
      end
    end
  end

  private

  def load_user_by_confirmation_token
    @user = User.find_by_confirmation_token(params[:token])
    if @user.nil?
      render json: { error_message: I18n.t('errors.messages.confirmation_token.invalid') }, status: :not_found
    end
  end
end
