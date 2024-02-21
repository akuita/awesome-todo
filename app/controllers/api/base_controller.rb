# typed: ignore
module Api
  class EmailVerificationError < StandardError; end

  class BaseController < ActionController::API
    include OauthTokensConcern
    include ActionController::Cookies
    include Pundit::Authorization

    # =======End include module======

    # Rescue from custom exceptions
    rescue_from Exceptions::InvalidFileTypeError, with: :base_render_invalid_file_type
    rescue_from Exceptions::BioLengthLimitError, with: :base_render_bio_length_limit
    rescue_from Exceptions::ProfileUpdateError, with: :base_render_profile_update_error
    rescue_from Exceptions::FileUploadError, with: :base_render_file_upload_error

    # Rescue from standard exceptions
    rescue_from ActiveRecord::RecordNotFound, with: :base_render_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :base_render_unprocessable_entity
    rescue_from Exceptions::AuthenticationError, with: :base_render_authentication_error
    rescue_from ActiveRecord::RecordNotUnique, with: :base_render_record_not_unique
    rescue_from EmailVerificationError, with: :base_render_email_verification_error
    rescue_from Pundit::NotAuthorizedError, with: :base_render_unauthorized_error

    def error_response(resource, error)
      {
        success: false,
        full_messages: resource&.errors&.full_messages,
        errors: resource&.errors,
        error_message: error.message,
        backtrace: error.backtrace
      }
    end

    private

    def base_render_invalid_file_type(exception)
      render json: { message: exception.message }, status: :unprocessable_entity
    end

    def base_render_bio_length_limit(exception)
      render json: { message: exception.message }, status: :unprocessable_entity
    end

    def base_render_profile_update_error(exception)
      render json: { message: I18n.t('profile_update.bio_length_error') }, status: :unprocessable_entity if exception.message == 'Bio length exceeded'
      render json: { message: I18n.t('profile_update.file_upload_error') }, status: :unprocessable_entity if exception.message == 'Invalid file type'
    end

    def base_render_file_upload_error(exception)
      render json: { message: I18n.t('profile_update.file_upload_error'), error_details: exception.message }, status: :unprocessable_entity
    end

    def base_render_record_not_found(_exception)
      render json: { message: I18n.t('common.404') }, status: :not_found
    end

    def base_render_unprocessable_entity(exception)
      # Merged the two different implementations of unprocessable_entity
      render json: { message: exception.record.errors.full_messages }, status: :unprocessable_entity
    end

    def base_render_authentication_error(_exception)
      render json: { message: I18n.t('common.404') }, status: :not_found
    end

    def base_render_unauthorized_error(_exception)
      render json: { message: I18n.t('common.errors.unauthorized_error') }, status: :unauthorized
    end

    def base_render_record_not_unique
      render json: { message: I18n.t('common.errors.record_not_uniq_error') }, status: :forbidden
    end

    def base_render_email_verification_error(exception)
      render json: { error: exception.message }, status: :unprocessable_entity
    end

    def custom_token_initialize_values(resource, client)
      token = CustomAccessToken.create(
        application_id: client.id,
        resource_owner: resource,
        scopes: resource.class.name.pluralize.downcase,
        expires_in: Doorkeeper.configuration.access_token_expires_in.seconds
      )
      @access_token = token.token
      @token_type = 'Bearer'
      @expires_in = token.expires_in
      @refresh_token = token.refresh_token
      @resource_owner = resource.class.name
      @resource_id = resource.id
      @created_at = resource.created_at
      @refresh_token_expires_in = token.refresh_expires_in
      @scope = token.scopes
    end

    def current_resource_owner
      return super if defined?(super)
    end
  end
end
