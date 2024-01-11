module Api
  class UsersController < ApplicationController
    before_action :validate_email_format, only: [:resend_confirmation]
    before_action :set_user, only: [:store_password]
    before_action :validate_password_hash, only: [:store_password]

    # ... other methods ...

    # Confirm email method
    def confirm_email
      token = params[:token]

      # Validation for token presence
      if token.blank?
        render json: { error: 'Token is required.' }, status: :bad_request
        return
      end

      begin
        if EmailConfirmation.new.mark_as_confirmed(token)
          user = User.find_by(confirmation_token: token)
          if user
            # Assuming there is a method in ApplicationController to create a session or token
            auth_token = create_auth_token_for(user)
            render json: {
              status: 200,
              message: 'Email confirmed successfully. You are now logged in.',
              auth_token: auth_token
            }, status: :ok
          else
            render json: { error: 'User not found.' }, status: :not_found
          end
        else
          render json: { error: 'Invalid or expired email confirmation token.' }, status: :not_found
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end

    def store_password
      if @user.update(password: params[:password_hash])
        render json: { status: 200, message: 'Password stored securely.' }, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def resend_confirmation
      email = params[:email]
      user = User.find_by_email(email)

      if user.nil?
        render json: { error: 'Email address not found.' }, status: :not_found
        return
      end

      token = EmailConfirmation.find_or_create_token(user)

      if token.created_at > 2.minutes.ago
        render json: { error: 'You can request to resend the confirmation link every 2 minutes.' }, status: :too_many_requests
        return
      end

      DeviseMailer.send_confirmation_email(user, token.token).deliver_now
      render json: { status: 200, message: 'Confirmation email resent successfully. Please check your inbox.' }, status: :ok
    end

    private
    
    def validate_email_format
      unless params[:email].match?(URI::MailTo::EMAIL_REGEXP)
        render json: { error: 'Please enter a valid email address.' }, status: :bad_request
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def validate_password_hash
      unless params[:password_hash].match(/\A[a-f0-9]{64}\z/i)
        render json: { error: 'Invalid password hash.' }, status: :bad_request
      end
    end

    # Assuming this is the method in ApplicationController to create a session or token
    def create_auth_token_for(user)
      # The implementation details of this method are not provided.
      # It should return an authentication token for the given user.
    end

    # ... other methods ...
  end
end
