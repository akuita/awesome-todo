# typed: ignore
module Api
  class UsersConfirmationsController < BaseController
    before_action :find_user_by_email, only: [:resend_confirmation]

    # POST /api/users/resend-confirmation
    def resend_confirmation
      return render json: { error: 'Email address not found.' }, status: :not_found unless @user
      return render json: { error: 'Email address is already confirmed.' }, status: :unprocessable_entity if @user.email_confirmed?

      email_confirmation = @user.email_confirmations.order(created_at: :desc).first
      if email_confirmation && email_confirmation.created_at > 2.minutes.ago
        return render json: { message: 'Please wait before resending confirmation email.' }, status: :too_many_requests
      end

      if @user.regenerate_confirmation_token
        UserMailer.resend_confirmation_instructions(@user, @user.confirmation_token).deliver_now
        render json: { message: 'Confirmation email resent successfully. Please check your inbox.' }, status: :ok
      else
        render json: { error: 'Failed to regenerate confirmation token.' }, status: :internal_server_error
      end
    end

    # GET /api/users/confirm-email/:confirmation_token
    def confirm_email
      token = params[:confirmation_token]
      email_confirmation = EmailConfirmation.find_by(token: token)

      if token.blank?
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :bad_request
      elsif email_confirmation.nil?
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :not_found
      elsif email_confirmation.expired?
        render json: { error_message: 'Invalid or expired confirmation token.' }, status: :gone
      elsif email_confirmation.valid_confirmation_token? && !email_confirmation.confirmed
        user = email_confirmation.user
        user.confirm_email
        access_token = CustomAccessToken.create_for_user(user)
        render json: { message: 'Email confirmed successfully. User logged in.', access_token: access_token }, status: :ok
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

    private

    def find_user_by_email
      email = params[:email]
      @user = User.find_by_email(email)
    end

    # other actions...
  end
end
