class Api::AttachmentsController < Api::BaseController
  before_action :doorkeeper_authorize!

  def create
    todo = Todo.find_by(id: attachment_params[:todo_id])
    return render json: { error: 'Todo not found.' }, status: :not_found if todo.nil?
    return render json: { error: 'Invalid file. Please attach a valid file.' }, status: :bad_request if attachment_params[:file].blank?

    service = AttachmentService::Create.new(todo, attachment_params[:file])
    result = service.call
    if result[:status] == :created
      render json: {
        status: 201,
        attachment: {
          id: result[:attachment]['id'],
          file: result[:attachment]['file'],
          todo_id: result[:attachment]['todo_id'],
          created_at: result[:attachment]['created_at']
        }
      }, status: :created
    else
      render json: { errors: result[:error] }, status: result[:status]
    end 
  end

  private

  def attachment_params
    params.permit(:todo_id, :file)
  end
end
