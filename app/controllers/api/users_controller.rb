class Api::UsersController < ApplicationController
  # Other actions ...

  def confirm_email
    token = params[:token]
    email_confirmation = EmailConfirmation.find_by(token: token)

    if email_confirmation.nil?
      render json: { error: 'Invalid or expired token.' }, status: :not_found
    elsif email_confirmation.expires_at < Time.current
      render json: { error: 'Invalid or expired token.' }, status: :gone
    elsif email_confirmation.confirmed?
      render json: { message: 'Email already confirmed' }, status: :ok
    else
      user = User.find_by(id: email_confirmation.user_id)
      if user.nil?
        render json: { error: 'User not found' }, status: :not_found
      else
        user.confirm_email
        email_confirmation.confirm!
        render json: { status: 200, message: 'Email confirmed successfully. You can now log in.' }, status: :ok
      end
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # Other actions ...
end
