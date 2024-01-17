
class Api::TodosController < ApplicationController
  before_action :set_todo, only: [:associate_with_category]
  before_action :set_category, only: [:associate_with_category]

  # POST /api/todos/:todo_id/associate_category/:category_id
  def associate_with_category
    todo_category = TodoCategory.new(todo: @todo, category: @category)
    if todo_category.save
      render json: { message: 'Todo successfully associated with category' }, status: :ok
    else
      render json: { error: todo_category.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def set_todo
    @todo = Todo.find(params[:todo_id])
  end

  def set_category
    @category = Category.find(params[:category_id])
  end
end
