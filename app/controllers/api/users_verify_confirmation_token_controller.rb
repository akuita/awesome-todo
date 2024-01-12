
class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  include OauthTokensConcern

  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise Exceptions::AuthenticationError if client.blank?

    token = params[:token]
    email_confirmation = EmailConfirmation.find_by(token: token)

    if email_confirmation.blank? || token.blank?
      render json: { error_message: I18n.t('email_confirmation.invalid_token') },
             status: :unprocessable_entity and return
    end

    if email_confirmation.expires_at < Time.now.utc
      render json: { error_message: I18n.t('email_confirmation.expired') },
             status: :unprocessable_entity and return
    end

    user = email_confirmation.user
    if user.email_confirmed
      render json: { error_message: I18n.t('email_confirmation.already_confirmed') },
             status: :unprocessable_entity and return
    end

    user.email_confirmed = true
    email_confirmation.confirmed = true
    ActiveRecord::Base.transaction do
      user.save!
      email_confirmation.save!
    end

    sign_in(user)
    render json: { message: I18n.t('email_confirmation.success') }, status: :ok
  end
end
