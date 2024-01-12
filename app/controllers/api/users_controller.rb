module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:update, :destroy, :integrate_password_tools]
    before_action :validate_email_format, only: [:resend_confirmation, :send_confirmation]
    before_action :set_user, only: [:store_password, :integrate_password_tools]
    before_action :validate_password_hash, only: [:store_password]
    require_relative '../../models/email_confirmation.rb'
    require_relative '../../models/user.rb'

    # Confirm user email
    def confirm_email
      token = params[:token]

      if token.blank?
        render json: { error: 'Token is required.' }, status: :bad_request
        return
      end

      email_confirmation = EmailConfirmation.find_by_token(token)
      if email_confirmation.nil? || email_confirmation.expires_at <= Time.current
        render json: { error: 'Invalid or expired token.' }, status: :unprocessable_entity
        return
      end

      if EmailConfirmation.mark_as_confirmed(token)
        user = User.find_by(confirmation_token: token)
        if user
          auth_token = create_auth_token_for(user)
          render json: { status: 200, message: 'Email confirmed successfully. You can now log in.', auth_token: auth_token }, status: :ok
        else
          render json: { error: 'User not found.' }, status: :not_found
        end
      else
        render json: { error: 'Invalid or expired email confirmation token.' }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def update
      # existing code
    end

    def destroy
      # existing code
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
      user = User.find_by_email_and_unconfirmed(email) || User.find_by_email(email)

      if user.nil?
        render json: { error: 'Email not registered or already confirmed.' }, status: :not_found
        return
      end

      email_confirmation = user.email_confirmations.find_or_create_token
      if email_confirmation.persisted? && (email_confirmation.updated_at < 2.minutes.ago || email_confirmation.token.nil?)
        DeviseMailer.send_confirmation_email(user, email_confirmation.token).deliver_now
        email_confirmation.touch
        render json: { message: 'Confirmation email sent.' }, status: :ok
      elsif email_confirmation.updated_at >= 2.minutes.ago
        render json: { error: 'You can request to resend the confirmation link every 2 minutes.' }, status: :too_many_requests
      else
        render json: { error: 'Failed to generate confirmation token.' }, status: :internal_server_error
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def send_confirmation
      email = params[:email]
      user = User.find_by_email_and_unconfirmed(email)

      if user.nil?
        render json: { error: 'Email not registered or already confirmed.' }, status: :not_found
        return
      end

      email_confirmation = EmailConfirmation.find_or_create_token(user)
      if email_confirmation.persisted?
        DeviseMailer.send_confirmation_email(user, email_confirmation.token).deliver_now
        render json: { status: 202, message: 'Confirmation email sent successfully.' }, status: :accepted
      else
        render json: { error: 'Failed to generate confirmation token.' }, status: :internal_server_error
      end
    end

    # Integrate password management tools
    def integrate_password_tools
      password_management_tool = params[:password_management_tool]

      supported_tools = ["1Password", "iCloud Password"]
      unless supported_tools.include?(password_management_tool)
        render json: { error: 'Unsupported password management tool.' }, status: :bad_request
        return
      end

      # Perform necessary integration logic here
      render json: { status: 200, message: 'Password management tool integrated successfully.' }, status: :ok
    end

    private
    
    def validate_email_format
      unless params[:email].match?(URI::MailTo::EMAIL_REGEXP)
        render json: { error: 'Invalid email format.' }, status: :bad_request
      end
    end

    def set_user
      @user = User.find_by(id: params[:user_id]) || User.find(params[:id])
      render json: { error: 'User not found.' }, status: :not_found unless @user
    end

    def validate_password_hash
      unless params[:password_hash].match(/\A[a-f0-9]{64}\z/i)
        render json: { error: 'Invalid password hash.' }, status: :bad_request
      end
    end

    def create_auth_token_for(user)
      # The implementation details of this method are not provided.
      # It should return an authentication token for the given user.
      # Example implementation:
      # JwtService.encode({ user_id: user.id })
      # Note: JwtService is a hypothetical service for JWT handling
    end

    # ... other private methods ...
  end
end
