class Api::TodosController < ApplicationController
  before_action :authenticate_user!

  def create
    todo = Todo.new(todo_params)

    if todo_params[:category_id].present?
      category = Category.find_by(id: todo_params[:category_id], user_id: current_user.id)
      unless category
        render json: { error: 'Category not found or not associated with the user' }, status: :unprocessable_entity
        return
      end
    end

    if todo.save
      render json: { message: 'Todo created successfully', todo: todo }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :priority, :recurring, :user_id, :category_id)
  end
end

class Todo < ApplicationRecord
  validates :title, presence: true, uniqueness: { scope: :user_id }
  validate :due_date_cannot_be_in_the_past
  validates :priority, inclusion: { in: Todo.priorities.keys }
  validates :recurring, inclusion: { in: Todo.recurrings.keys }, allow_nil: true
end
