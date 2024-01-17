
class Api::TodoCategoriesController < Api::BaseController
  before_action :doorkeeper_authorize!, except: [:associate_todo_with_category]

  def create
    todo = Todo.find_by(id: params[:todo_id])
    category = Category.find_by(id: params[:category_id])

    if todo.nil?
      render json: { error: 'Todo not found.' }, status: :not_found
    elsif category.nil?
      render json: { error: 'Category not found.' }, status: :not_found
    else
      todo_category = TodoCategory.new(todo: todo, category: category)
      if todo_category.save
        render json: { status: 201, todo_category: todo_category.as_json }, status: :created
      else
        render json: { error: todo_category.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def associate_todo_with_category
    todo = Todo.find(params[:todo_id])
    category = Category.find(params[:category_id])

    todo_category = TodoCategory.new(todo: todo, category: category)
    if todo_category.save
      render json: { message: 'Todo successfully associated with category.' }, status: :created
    else
      render json: { error: todo_category.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end
end
