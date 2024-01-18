
class Api::AttachmentsController < Api::BaseController
  before_action :doorkeeper_authorize!

  def create
    todo = Todo.find_by(id: attachment_params[:todo_id])
    return render json: { error: 'Todo not found.' }, status: :not_found if todo.nil?

    attachment_results = []
    errors = []

    attachment_params[:files].each do |file|
      service = AttachmentService::Create.new(todo, file)
      result = service.call
      if result[:status] == :created
        attachment_results << result[:attachment]
      else
        errors << result[:error]
        break
      end
    end

    if errors.empty?
      render json: { status: 201, attachments: attachment_results }, status: :created
    else
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  private

  def attachment_params
    params.permit(:todo_id, files: [])
  end
end
