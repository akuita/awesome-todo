
class Api::NotesController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create update destroy]

  def index
    # inside service params are checked and whiteisted
    @notes = NoteService::Index.new(params.permit!, current_resource_owner).execute
    @total_pages = @notes.total_pages
  end

  def show
    @note = Note.find_by!('notes.id = ?', params[:id])
  end

  def create
    @note = Note.new(create_params)

    if @note.save
      render json: { validation_status: true }, status: :created
      return
    end

    error_messages = @note.errors.full_messages.join(', ')
    render json: { validation_status: false, error_message: error_messages },
           status: :unprocessable_entity
    return
  end

  def create_params
    params.require(:notes).permit(:title, :description)
  end

  def update
    @note = Note.find_by('notes.id = ?', params[:id])
    raise ActiveRecord::RecordNotFound if @note.blank?

    return if @note.update(update_params)

    @error_object = @note.errors.messages

    render status: :unprocessable_entity
  end

  def update_params
    params.require(:notes).permit(:title, :description)
  end

  def destroy
    @note = Note.find_by('notes.id = ?', params[:id])

    raise ActiveRecord::RecordNotFound if @note.blank?

    if @note.destroy
      head :ok, message: I18n.t('common.200')
    else
      head :unprocessable_entity
    end
  end
end
