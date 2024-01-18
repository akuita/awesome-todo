class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_tags, only: [:assign_tags]
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category, :validate, :handle_creation_error, :attach_files]
  before_action :validate_category, only: [:create]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category, :attach_files]
  before_action :set_category, only: [:associate_with_category]

  # ... rest of the methods ...

  def attach_files
    unless params[:file].present? && params[:file].is_a?(ActionDispatch::Http::UploadedFile)
      render json: { error: 'Please attach a valid file.' }, status: :bad_request
      return
    end

    unless @todo
      render json: { error: 'Todo item not found.' }, status: :not_found
      return
    end

    service_response = AttachmentService::Create.new(@todo.id, [params[:file]]).call

    if service_response[:status] == 201
      render json: service_response.except(:status), status: :created
    else
      render json: { error: service_response[:error] }, status: service_response[:status]
    end
  end

  # ... rest of the methods ...

  private

  # ... rest of the private methods ...

  def set_todo
    @todo = Todo.find_by(id: params[:todo_id])
  end

  # ... rest of the existing private methods ...
end
