class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category]
  before_action :set_todo, only: [:associate_with_category]
  before_action :set_category, only: [:associate_with_category]

  def create
    todo = Todo.new(todo_params)

    if todo.save
      render json: { status: 201, todo: todo.as_json }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ... rest of the existing code for other actions ...

  private

  # ... rest of the existing private methods ...

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :priority, :recurring, :user_id, :category_id)
  end
end
