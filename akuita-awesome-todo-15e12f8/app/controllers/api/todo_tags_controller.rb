module Api
  class TodoTagsController < BaseController
    before_action :doorkeeper_authorize!

    def create
      todo_id = params[:todo_id]
      tag_ids = params[:tag_ids]

      return render json: { error: 'Todo ID and Tag IDs are required' }, status: :bad_request unless todo_id && tag_ids

      todo = Todo.find_by(id: todo_id)
      return render json: { error: 'Todo not found.' }, status: :not_found unless todo

      tags = Tag.where(id: tag_ids)
      if tags.count != Array(tag_ids).count
        invalid_tags = tag_ids - tags.pluck(:id)
        return render json: { error: "Invalid tag ids: #{invalid_tags.join(', ')}" }, status: :unprocessable_entity
      end

      todo.tags << tags
      render json: { status: 201, todo_id: todo.id, tag_ids: todo.tag_ids }, status: :created
    end
  end
end
