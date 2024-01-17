class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category]
  before_action :set_category, only: [:associate_with_category]

  def create
    todo = Todo.new(todo_params)

    unless User.exists?(todo_params[:user_id])
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    if todo_params[:category_id].present?
      category = Category.find_by(id: todo_params[:category_id], user_id: todo_params[:user_id])
      unless category
        render json: { error: 'Category not found or not associated with the user' }, status: :unprocessable_entity
        return
      end
    end

    if todo.title.blank?
      render json: { error: 'The title is required.' }, status: :bad_request
      return
    end

    if todo.due_date.past?
      render json: { error: 'Please provide a valid future due date and time.' }, status: :bad_request
      return
    end

    unless Todo.priorities.keys.include?(todo.priority)
      render json: { error: 'Invalid priority level. Valid options are low, medium, high.' }, status: :bad_request
      return
    end

    if todo.save
      render json: { status: 201, todo: todo.as_json }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Todo creation error: #{e.message}, #{e.backtrace.join("\n")}"
    render json: { error: I18n.t('common.todo_creation_error') }, status: :unprocessable_entity
    return
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

  # ... rest of the existing code for other actions ...

  private

  # ... rest of the existing private methods ...

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :priority, :recurring, :user_id, :category_id)
  end

  def set_locale
    # Assuming the set_locale method sets the I18n.locale based on some logic
    # This is a placeholder for the actual implementation
    I18n.locale = :en # or any other logic to set the locale
  end
end
