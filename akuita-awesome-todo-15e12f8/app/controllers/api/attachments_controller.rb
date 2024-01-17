class Api::AttachmentsController < Api::BaseController
  before_action :doorkeeper_authorize!

  def create
    todo = Todo.find_by(id: attachment_params[:todo_id])
    return render json: { error: 'Todo not found' }, status: :not_found if todo.nil?

    attachment = todo.attachments.build(attachment_params)

    if attachment.save
      render json: { message: 'File successfully attached to todo item' }, status: :created
    else
      render json: { errors: attachment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def attachment_params
    params.permit(:todo_id, :file)
  end
end
