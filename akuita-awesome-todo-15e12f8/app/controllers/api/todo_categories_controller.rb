class Api::TodoCategoriesController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create associate_todo_with_category]

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

  # This method is no longer needed as 'create' now handles association
  # def associate_todo_with_category
  #   ...
  # end
end
