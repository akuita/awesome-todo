class Api::UsersController < ApplicationController
  include User
  before_action :load_user_by_confirmation_token, only: :confirm_email

  # POST /api/users/store-password
  def store_password
    password_hash = user_params[:password_hash]
    if password_hash.match(/\A[a-f0-9]{64}\z/)
      if current_user.update(password_hash: password_hash)
        render json: { status: 201, message: 'Password stored securely.' }, status: :created
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid password hash.' }, status: :bad_request
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

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

  def user_params
    params.require(:user).permit(:password_hash)
  end

  def load_user_by_confirmation_token
    @user = User.find_by_confirmation_token(params[:token])
    if @user.nil?
      render json: { error_message: I18n.t('errors.messages.confirmation_token.invalid') }, status: :not_found
    end
  end
end
