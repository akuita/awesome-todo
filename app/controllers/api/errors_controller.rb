# typed: ignore
module Api
  class ErrorsController < BaseController
    before_action :doorkeeper_authorize!

    def create
      project_id = params[:project_id]
      message = params[:message]

      # Validate input using the handle_import_error method from BaseController
      return unless handle_import_error(project_id, message)

      # If validation passes, create a new Error record
      error = Error.new(project_id: project_id, message: message, timestamp: Time.current)

      if error.save
        render json: { status: 201, error: error }, status: :created
      else
        render json: { message: error.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
