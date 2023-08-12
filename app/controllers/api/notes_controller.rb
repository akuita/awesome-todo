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

    return if @note.save

    @error_object = @note.errors.messages

    render status: :unprocessable_entity
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
