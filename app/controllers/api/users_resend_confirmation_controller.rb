# /app/controllers/api/users_resend_confirmation_controller.rb
class Api::UsersResendConfirmationController < Api::BaseController
  before_action :validate_email_format, only: [:create]

  def create
    user = User.find_by(email: params[:email])

    if user.nil?
      render json: { message: "Email address not found." }, status: :not_found
    elsif user.email_confirmed
      render json: { message: "Email address already confirmed." }, status: :not_found
    elsif user.email_confirmations.order(created_at: :desc).first&.created_at&.> 2.minutes.ago || (user.confirmation_sent_at.present? && user.confirmation_sent_at > 2.minutes.ago)
      render json: { message: "You can request to resend the confirmation link every 2 minutes." }, status: :too_many_requests
    else
      email_confirmation = EmailConfirmation.create!(
        user: user,
        token: SecureRandom.hex(10),
        confirmed: false,
        expires_at: 2.days.from_now
      )
      UserMailer.confirmation_email(user).deliver_later
      render json: { status: 200, message: "Confirmation email resent successfully. Please check your inbox." }, status: :ok
      user.update(confirmation_token: email_confirmation.token, confirmation_sent_at: Time.current)
    end
  rescue => e
    render json: { message: e.message }, status: :internal_server_error
  end

  private

  def validate_email_format
    unless params[:email].match?(URI::MailTo::EMAIL_REGEXP)
      render json: { message: "Invalid email format." }, status: :bad_request
    end
  end

  def user_params
    params.require(:user).permit(:email)
  end
end
