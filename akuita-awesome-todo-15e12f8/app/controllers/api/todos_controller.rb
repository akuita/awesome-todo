class Api::TodosController < Api::BaseController
  before_action :authenticate_user!, except: [:assign_tags]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category, :assign_category, :attach_files]
  before_action :set_tags, only: [:assign_tags]
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category, :validate, :handle_creation_error, :assign_category, :attach_files]
  before_action :validate_category, only: [:create]
  before_action :set_category, only: [:associate_with_category]

  def create
    todo = Todo.new(todo_params)

    Todo.transaction do
      unless User.exists?(id: todo_params[:user_id])
        render json: { error: I18n.t('activerecord.errors.models.user.not_found') }, status: :not_found
        return
      end

      if todo.title.blank?
        render json: { error: 'The title is required.' }, status: :bad_request
        return
      end
      
      existing_todo = Todo.find_by(title: todo_params[:title], user_id: todo_params[:user_id])
      if existing_todo
        render json: { error: I18n.t('activerecord.errors.messages.title_already_exists') }, status: :unprocessable_entity
        return
      end

      if todo.due_date.present? && todo.due_date.past?
        render json: { error: 'Please provide a valid future due date and time.' }, status: :bad_request
        return
      elsif todo.due_date.nil? || !todo.due_date.future?
        render json: { error: 'Please provide a valid future due date and time.' }, status: :bad_request
        return
      end
      
      unless Todo.priorities.keys.include?(todo.priority) || todo.priority.blank?
        render json: { error: 'Invalid priority level. Valid options are low, medium, high.' }, status: :bad_request
        return
      end

      if todo.save
        render json: { status: 201, todo: TodoSerializer.new(todo).serializable_hash }, status: :created
        associate_attachments(todo) if params[:file].present?
      else        
        render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue StandardError => e
    log_todo_creation_error(e.message, todo_params[:user_id])
  end

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
    unless User.exists?(id: user_id)
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    Rails.logger.error "Todo creation error for user #{user_id}: #{error_message}"
    render json: { status: 200, error: { message: error_message, user_notified: true } }, status: :ok
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :priority, :recurring, :user_id)
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
