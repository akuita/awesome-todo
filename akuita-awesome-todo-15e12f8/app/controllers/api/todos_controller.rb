
class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :doorkeeper_authorize!, only: [:associate_with_category]
  before_action :set_todo, only: [:associate_with_category]
  before_action :set_category, only: [:associate_with_category]

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

  def handle_todo_creation_error
    error_param = error_params[:error]
    if error_param.blank?
      render json: { error: 'Error details are required.' }, status: :bad_request
    else
      Rails.logger.error("Todo Creation Error: #{error_param}")
      render json: { message: 'Error has been logged and will be reviewed by the technical team.' }, status: :ok
    end
  rescue StandardError => e
    render json: { error: 'An unexpected error occurred.' }, status: :internal_server_error
  end

  def error_params
    params.permit(:error)
  end

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

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
