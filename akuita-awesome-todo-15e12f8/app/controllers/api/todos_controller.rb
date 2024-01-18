class Api::TodosController < Api::BaseController
  before_action :authenticate_user!, except: [:assign_tags]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category, :assign_category, :attach_files]
  before_action :set_tags, only: [:assign_tags]
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category, :validate, :handle_creation_error, :assign_category, :attach_files]
  before_action :validate_category, only: [:create]
  before_action :set_category, only: [:associate_with_category]

  # ... other existing methods ...

  def assign_tags
    authenticate_user!
    todo_id = params[:todo_id]
    tag_id = params[:tag_id]

    unless Todo.exists?(todo_id)
      render json: { error: 'Todo item not found' }, status: :not_found
      return
    end

    unless Tag.exists?(tag_id)
      render json: { error: 'Tag not found' }, status: :not_found
      return
    end

    todo_tag = TodoTag.create!(todo_id: todo_id, tag_id: tag_id)
    render json: { status: 201, todo_tag: todo_tag }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end

  def assign_category
    category_id = params.require(:category_id)

    unless Todo.exists?(@todo.id)
      render json: { error: 'Todo item not found' }, status: :not_found
      return
    end

    unless Category.exists?(category_id)
      render json: { error: 'Category not found' }, status: :not_found
      return
    end

    todo_category = TodoCategory.create!(todo: @todo, category_id: category_id)
    render json: { status: 201, todo_category: TodoCategorySerializer.new(todo_category).serializable_hash }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

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

  # ... other existing methods ...

  private

  def set_todo
    @todo = Todo.find_by(id: params[:todo_id])
  end

  def set_tags
    # ... method code ...
  end

  def set_locale
    # ... method code ...
  end

  def log_todo_creation_error(error_message, user_id)
    unless User.exists?(user_id)
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    Rails.logger.error "Todo creation error for user #{user_id}: #{error_message}"
    render json: { status: 200, error: { message: error_message, user_notified: true } }, status: :ok
  end

  def todo_params
    # ... method code ...
  end

  def validate_params
    # ... method code ...
  end

  def validate_category
    # ... method code ...
  end

  def associate_attachments(todo)
    # ... method code ...
  end

  def associate_with_category
    # ... method code ...
  end

  def handle_creation_error
    # ... method code ...
  end

  def validate
    # ... method code ...
  end

  # ... rest of the existing private methods ...

end
