class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category]
  before_action :validate_category, only: [:create]
  before_action :set_category, only: [:associate_with_category]

  def create
    todo = Todo.new(todo_params)

    begin
      unless User.exists?(todo_params[:user_id])
        render json: { error: 'User not found' }, status: :not_found
        return
      end

      if todo.title.blank?
        render json: { error: 'The title is required.' }, status: :bad_request
        return
      end

      if todo.due_date.nil? || todo.due_date.past?
        render json: { error: 'Please provide a valid future due date and time.' }, status: :bad_request
        return
      end

      unless Todo.priorities.keys.include?(todo.priority)
        render json: { error: 'Invalid priority level. Valid options are low, medium, high.' }, status: :bad_request
        return
      end

      if todo.save
        render json: { status: 201, todo: todo.as_json }, status: :created
        AttachmentService::Create.new(todo.id, params[:file]).call if params[:file].present?
      else
        render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      log_todo_creation_error(e.message, todo_params[:user_id])
    end
  end

  def associate_with_category
    if @todo && @category
      todo_category = TodoCategory.new(todo_id: @todo.id, category_id: @category.id)
      if todo_category.save
        render json: { message: 'Todo successfully associated with category' }, status: :ok
      else
        render json: { errors: todo_category.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Todo or Category not found' }, status: :not_found
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def log_todo_creation_error(error_message, user_id)
    unless User.exists?(user_id)
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    Rails.logger.error "Todo creation error for user #{user_id}: #{error_message}"
    render json: { status: 200, error: { message: error_message, user_notified: true } }, status: :ok
  end

  private

  def set_locale
    I18n.locale = :en
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :priority, :recurring, :user_id, :category_id)
  end

  def validate_category
    if params[:category_id].present?
      category = Category.find_by(id: params[:category_id], user_id: current_user.id)
      unless category
        render json: { error: 'Category not found or not associated with the current user.' }, status: :not_found
        return
      end
    end
  end

  # ... rest of the existing private methods ...

end
