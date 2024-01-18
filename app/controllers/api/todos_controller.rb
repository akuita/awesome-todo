class Api::TodosController < ApplicationController
  before_action :set_todo, only: [:associate_with_category]
  before_action :set_category, only: [:associate_with_category]

  # POST /api/todos
  def create
    begin
      # existing todo creation logic
    rescue => e
      Rails.logger.error "Todo creation error: #{e.message}, #{e.backtrace.join("\n")}"
      render json: { error: I18n.t('common.todo_creation_error') }, status: :unprocessable_entity
    end
  end

  # POST /api/todos/:todo_id/associate_category/:category_id
  def associate_with_category
    todo_category = TodoCategory.new(todo: @todo, category: @category)
    if todo_category.save
      render json: { message: 'Todo successfully associated with category' }, status: :ok
    else
      render json: { error: todo_category.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  # POST /api/todos/validate
  def validate
    title = params[:title]
    due_date = params[:due_date]

    if title.blank? || due_date.blank?
      render json: { error: 'Title and due date are required.' }, status: :bad_request
      return
    end

    begin
      due_date = DateTime.parse(due_date)
    rescue ArgumentError
      render json: { error: 'Invalid due date format.' }, status: :unprocessable_entity
      return
    end

    if current_user.todos.exists?(title: title)
      render json: { error: 'A todo with this title already exists.' }, status: :unprocessable_entity
      return
    end

    if current_user.todos.where.not(id: params[:id]).exists?(due_date: due_date)
      render json: { error: 'This due date conflicts with another todo.' }, status: :unprocessable_entity
      return
    end

    render json: { message: 'Todo item details are valid.' }, status: :ok
  end

  private

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_category
    @category = Category.find(params[:category_id])
  end
end
