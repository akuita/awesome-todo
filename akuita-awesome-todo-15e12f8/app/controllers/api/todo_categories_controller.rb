
class Api::TodoCategoriesController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create associate_todo_with_category]

  def associate_todo_with_category
    todo_id = params[:todo_id]
    category_id = params[:category_id]

    return render json: { error: 'Todo ID and Category ID are required' }, status: :bad_request unless todo_id && category_id

    todo = Todo.find(todo_id)
    category = Category.find(category_id)

    TodoCategory.create!(todo: todo, category: category)
    render json: { message: 'Todo successfully associated with category' }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end
end
