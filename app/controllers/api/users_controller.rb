class Api::UsersController < ApplicationController
  before_action :load_email_confirmation, only: [:confirm_email]

  # GET /api/users/confirm-email/:token
  def confirm_email
    if @email_confirmation.nil?
      render json: { error: 'Token not found' }, status: :not_found
    elsif @email_confirmation.expired?
      render json: { error: 'Invalid or expired email confirmation token.' }, status: :unprocessable_entity
    else
      @user.confirm_email
      render json: { status: 200, message: 'Email address confirmed successfully.' }, status: :ok
    end
  end

  private

  def load_email_confirmation
    token = params[:token]
    @email_confirmation = EmailConfirmation.find_by(token: token)
    @user = email_confirmation&.user
  end
end
