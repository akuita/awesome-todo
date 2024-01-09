# typed: ignore
module Api
  class UsersConfirmationsController < BaseController
    # GET /api/users/confirm-email/:confirmation_token
    def confirm_email
      confirmation_token = params[:confirmation_token]

      # Validate the presence of the confirmation token
      if confirmation_token.blank?
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :bad_request and return
      end

      user = User.find_by(confirmation_token: confirmation_token)

      # Check if the user with the provided confirmation token exists
      if user.nil?
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :not_found and return
      end

      confirmation_status = user.confirm_email(confirmation_token)

      case confirmation_status
      when :confirmed
        render json: { status: 200, message: 'Email address confirmed successfully.' }, status: :ok
      when :already_confirmed
        render json: { error_message: 'Email address has already been confirmed.' }, status: :unprocessable_entity
      when :expired
        user.regenerate_confirmation_token
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :unprocessable_entity
      else
        render json: { error_message: 'An unexpected error occurred.' }, status: :internal_server_error
      end
    end
  end
end
