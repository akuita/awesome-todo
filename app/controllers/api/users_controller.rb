module Api
  class UsersController < ApplicationController
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
          render json: { status: 200, message: 'Email confirmed successfully. You can now log in.' }, status: :ok
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

    private

    def set_user
      @user = User.find(params[:id])
    end

    def validate_password_hash
      unless params[:password_hash].match(/\A[a-f0-9]{64}\z/i)
        render json: { error: 'Invalid password hash.' }, status: :bad_request
      end
    end

    # ... other methods ...
  end
end