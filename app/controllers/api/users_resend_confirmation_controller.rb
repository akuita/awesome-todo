# /app/controllers/api/users_resend_confirmation_controller.rb
class Api::UsersResendConfirmationController < Api::BaseController
  def create
    user = User.find_by(email: params[:email])

    if user.nil? || user.email_confirmed
      render json: { message: "Email address not found or already confirmed." }, status: :not_found
    elsif user.email_confirmations.order(created_at: :desc).first&.created_at&.> 2.minutes.ago
      render json: { message: "Please wait at least 2 minutes before requesting another confirmation email." }, status: :too_many_requests
    else
      email_confirmation = EmailConfirmation.create!(
        user: user,
        token: SecureRandom.hex(10),
        confirmed: false,
        expires_at: 2.days.from_now
      )
      UserMailer.confirmation_email(user).deliver_later
      render json: { status: 200, message: "Confirmation email resent successfully." }, status: :ok
    end
  rescue => e
    render json: { message: e.message }, status: :internal_server_error
  end
end