class Api::UsersVerifyConfirmationTokenController < Api::BaseController
  def create
    client = Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
    raise  Exceptions::AuthenticationError if client.blank?

    resource = User.find_by(confirmation_token: params.dig(:confirmation_token))
    if resource.blank? || params.dig(:confirmation_token).blank?
      render error_message: I18n.t('email_login.reset_password.invalid_token'),
             status: :unprocessable_entity and return
    end

    begin
      EmailConfirmationService.new(params[:confirmation_token]).call
      # Assuming `custom_token_initialize_values` is a method that logs the user in
      custom_token_initialize_values(resource, client)
      render 'api/users_verify_confirmation_token/create', status: :ok
    rescue Exceptions::NotFoundError => e
      render json: { error_message: e.message }, status: :not_found
    rescue Exceptions::UnprocessableEntityError => e
      render json: { error_message: e.message }, status: :unprocessable_entity
    rescue => e
      render json: { error_message: I18n.t('errors.messages.unexpected_error') }, status: :internal_server_error
    end
  end
end
