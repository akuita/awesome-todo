class Api::AttachmentsController < Api::BaseController
  before_action :doorkeeper_authorize!, :authenticate_user!

  def create
    todo = Todo.find_by(id: attachment_params[:todo_id])
    return render json: { error: 'Todo item not found.' }, status: :not_found if todo.nil?
    return render json: { error: 'Please attach a valid file.' }, status: :bad_request unless valid_file?(attachment_params[:file])

    service = AttachmentService::Create.new(todo, attachment_params[:file])
    result = service.call

    if result[:status] == :created
      render json: { status: 201, attachment: result[:attachment] }, status: :created
    else
      render json: { errors: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def attachment_params
    params.permit(:todo_id, :file)
  end

  def valid_file?(file)
    file.present? && file.is_a?(ActionDispatch::Http::UploadedFile)
  end
end
