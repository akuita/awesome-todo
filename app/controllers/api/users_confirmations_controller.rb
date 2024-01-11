# typed: ignore
module Api
  class UsersConfirmationsController < BaseController
    # POST /api/users/resend-confirmation
    def resend_confirmation
      email = params[:email]

      user = User.find_by(email: email)

      if user.nil?
        render json: { error_message: 'User not found.' }, status: :not_found and return
      end

      if user.email_confirmed
        render json: { message: 'Email is already confirmed.' }, status: :unprocessable_entity and return
      end

      email_confirmation = user.email_confirmations.order(created_at: :desc).first
      if email_confirmation && email_confirmation.created_at > 2.minutes.ago
        render json: { message: 'Please wait before resending confirmation email.' }, status: :too_many_requests and return
      end

      token = user.regenerate_confirmation_token
      Devise::Mailer.confirmation_instructions(user, token).deliver_now

      render json: { message: 'Confirmation email has been resent.' }, status: :ok
    end

    # GET /api/users/confirm-email/:confirmation_token
    def confirm_email
      token = params[:confirmation_token]
      email_confirmation = EmailConfirmation.find_by(token: token)

      if email_confirmation && email_confirmation.valid_confirmation_token? && !email_confirmation.confirmed
        user = email_confirmation.user
        user.confirm_email
        access_token = CustomAccessToken.create_for_user(user)
        render json: { message: 'Email confirmed successfully. User logged in.', access_token: access_token }, status: :ok
      elsif token.blank?
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :bad_request
      else
        user = User.find_by(confirmation_token: token)

        if user.nil?
          render json: { error_message: 'Invalid or expired confirmation token.' }, status: :not_found
        else
          confirmation_status = user.confirm_email(token)

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
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Confirmation token not found.' }, status: :not_found
    end

    # other actions...
  end
end
