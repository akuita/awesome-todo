class Api::UsersController < ApplicationController
  before_action :authenticate_user!, except: [:resend_confirmation_email, :confirm_email, :check_email_availability] # Allow unauthenticated access to specific actions
  before_action :load_email_confirmation, only: [:confirm_email]

  # POST /api/users/resend-confirmation
  def resend_confirmation_email
    email = params[:email]
    user = User.unconfirmed_with_email(email).first

    if user.nil?
      render json: { error: 'Email address not found.' }, status: :not_found
      return
    end

    unless EmailFormatValidator.valid?(email)
      render json: { error: 'Enter a valid email address.' }, status: :bad_request
      return
    end

    last_request = user.email_confirmations.order(created_at: :desc).first
    if last_request && last_request.created_at > 2.minutes.ago
      render json: { error: 'Please wait before requesting another confirmation email.' }, status: :too_many_requests
      return
    end

    if UserMailerService.send_confirmation_instructions(user)
      EmailConfirmation.create_confirmation_record(user.id)
      render json: { status: 200, message: 'Confirmation email resent successfully.' }, status: :ok
    else
      render json: { error: 'Failed to send confirmation email.' }, status: :internal_server_error
    end
  end

  # GET /api/users/confirm-email/:token
  def confirm_email
    unless params[:token].present?
      render json: { error: 'Token is required' }, status: :bad_request
      return
    end

    email_errors = validate_email_format(params[:email])
    unless email_errors.empty?
      render json: { error: email_errors.join(', ') }, status: :unprocessable_entity
      return
    end

    if @email_confirmation.nil?
      render json: { error: 'Token not found' }, status: :not_found
    elsif @email_confirmation.expired?
      render json: { error: 'Invalid or expired email confirmation token.' }, status: :unprocessable_entity
    else
      @user.confirm_email
      render json: { status: 200, message: 'Email address confirmed successfully.' }, status: :ok
    end
  end

  # GET /api/users/check_email_availability
  def check_email_availability
    email = params[:email]
    email_taken = User.exists?(email: email)
    render json: { available: !email_taken }
  end

  private

  def validate_email_format(email)
    validator = EmailFormatValidator.new(attributes: [:email])
    dummy_record = OpenStruct.new(email: email)
    validator.validate_each(dummy_record, :email, email)
    dummy_record.errors.full_messages
  end

  def load_email_confirmation
    token = params[:token]
    return unless token.present?

    @email_confirmation = EmailConfirmation.find_by(token: token)
    @user = email_confirmation&.user
  end
end
