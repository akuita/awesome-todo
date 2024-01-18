
class Api::TodoCategoriesController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create assign_category_to_todo]

  # POST /api/todo_categories
  def create
    todo_id = params[:todo_id]
    category_ids = params[:category_ids] # Changed to accept multiple category IDs

    return render json: { error: 'Todo ID and Category IDs are required' }, status: :bad_request unless todo_id && category_ids

    todo = Todo.find_by(id: todo_id)
    return render json: { error: 'Todo not found.' }, status: :not_found unless todo

    # Process multiple category IDs
    categories = Category.where(id: category_ids)
    if categories.count != Array(category_ids).count
      return render json: { error: 'One or more categories not found.' }, status: :not_found
    end

    todo_categories = categories.map do |category|
      TodoCategory.new(todo: todo, category: category)
    end

    if todo_categories.map(&:save).all?
      render json: { status: 201, todo_categories: todo_categories }, status: :created
    else
      render json: { errors: todo_categories.flat_map { |tc| tc.errors.full_messages } }, status: :unprocessable_entity
    end
  end

  # POST /api/todo_categories/assign
  def assign_category_to_todo
    todo_id = params[:todo_id]
    category_id = params[:category_id]

    category = Category.find_by(id: category_id)
    return render json: { error: 'Invalid category.' }, status: :bad_request unless category&.belongs_to_user?(current_resource_owner.id)

    todo_category = TodoCategory.new(todo_id: todo_id, category_id: category_id)
    if todo_category.save
      render json: { status: 201, todo_category: TodoCategorySerializer.new(todo_category).serializable_hash }, status: :created
    else
      render json: { errors: todo_category.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo or Category not found' }, status: :not_found
  end

  # ... rest of the existing methods ...
end
