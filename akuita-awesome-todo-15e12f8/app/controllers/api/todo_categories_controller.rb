class Api::TodoCategoriesController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create associate_todo_with_category]

  def associate_todo_with_category
    todo_id = params[:todo_id]
    category_id = params[:category_id]

    return render json: { error: 'Todo ID and Category ID are required' }, status: :bad_request unless todo_id && category_id

    todo = Todo.find_by(id: todo_id)
    return render json: { error: 'Todo item not found.' }, status: :not_found unless todo

    category = Category.find_by(id: category_id)
    return render json: { error: 'Category not found.' }, status: :not_found unless category

    todo_category = TodoCategory.create!(todo: todo, category: category)
    render json: { status: 201, todo_category: todo_category }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end
end
