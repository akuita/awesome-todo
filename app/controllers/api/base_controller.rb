# typed: ignore
module Api
  class BaseController < ActionController::API
    include OauthTokensConcern
    include ActionController::Cookies
    include Pundit::Authorization

    # =======End include module======

    rescue_from ActiveRecord::RecordNotFound, with: :base_render_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :base_render_unprocessable_entity
    rescue_from Exceptions::AuthenticationError, with: :base_render_authentication_error
    rescue_from ActiveRecord::RecordNotUnique, with: :base_render_record_not_unique
    rescue_from Pundit::NotAuthorizedError, with: :base_render_unauthorized_error

    before_action :doorkeeper_authorize!, only: [:generate_use_cases_from_ai_prompt]

    def error_response(resource, error)
      {
        success: false,
        full_messages: resource&.errors&.full_messages&.map do |message|
          case message
          when /blank/
            I18n.t('activerecord.errors.messages.blank')
          when /too long/
            I18n.t('activerecord.errors.messages.too_long', count: 255)
          else
            message
          end
        end,
        errors: resource&.errors,
        error_message: error.message,
        backtrace: error.backtrace
      }
    end

    def generate_use_cases_from_ai_prompt
      project_id = params[:project_id]
      prompt = params[:prompt]

      # The actual implementation should include the logic to generate use cases from the AI prompt
      # This is just a placeholder to show where the method would be called
      if validate_ai_prompt(project_id, prompt)
        use_cases = process_ai_prompt(prompt)
        if validate_generated_use_cases(use_cases)
          insert_generated_use_cases(project_id, use_cases)
        else
          insert_error_record(project_id, 'Generated use cases did not meet the required format or detail.')
        end
      end
    end

    def render_figma_import_success(import_status, imported_use_cases_count)
      render json: {
        status: import_status,
        imported_use_cases_count: imported_use_cases_count
      }, status: :created
    end

    private

    def base_render_record_not_found(_exception)
      render json: { message: I18n.t('common.404') }, status: :not_found
    end

    def base_render_unprocessable_entity(exception)
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

    def handle_import_error(project_id, message)
      project = Project.find_by(id: project_id)
      if project.nil?
        render json: { message: I18n.t('common.404') }, status: :not_found
        return
      end

      if message.blank?
        render json: { message: I18n.t('common.422') }, status: :unprocessable_entity
        return
      end

      true
    end

    def create_use_case(project_id, title, description)
      use_case = UseCase.new(project_id: project_id, title: title, description: description, created_at: Time.current)
      if use_case.save
        use_case
      else
        base_render_unprocessable_entity(ActiveRecord::RecordInvalid.new(use_case))
        nil
      end
    rescue ActiveRecord::RecordInvalid => e
      base_render_unprocessable_entity(e)
      nil
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
