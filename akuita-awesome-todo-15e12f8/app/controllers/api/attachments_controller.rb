class Api::AttachmentsController < Api::BaseController
  before_action :doorkeeper_authorize!

  def create
    todo = Todo.find_by(id: attachment_params[:todo_id])
    return render json: { error: 'Todo item not found.' }, status: :not_found if todo.nil?
    return render json: { error: 'Invalid file. Please attach a valid file.' }, status: :bad_request if attachment_params[:file].blank?

    attachment = todo.attachments.build(attachment_params)

    if attachment.save
      render json: {
        status: 201,
        attachment: {
          id: attachment.id,
          file: attachment.file,
          todo_id: attachment.todo_id,
          created_at: attachment.created_at.iso8601
        }
      }, status: :created
    else
      render json: { errors: attachment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def attachment_params
    params.permit(:todo_id, :file)
  end
end
