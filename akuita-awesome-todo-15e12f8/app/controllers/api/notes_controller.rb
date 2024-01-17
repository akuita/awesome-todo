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
    begin
      @note = Note.new(create_params)

      if @note.save
        render json: { validation_status: true, note: @note }, status: :created
        return
      end

      error_messages = @note.errors.full_messages.join(', ')
      render json: { validation_status: false, error_message: error_messages },
             status: :unprocessable_entity
      return
    rescue StandardError => e
      Rails.logger.error("Error creating note: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      render json: { error_message: I18n.t('common.todo_creation_error') },
             status: :internal_server_error
      return
    end
  end

  def update
    @note = Note.find_by('notes.id = ?', params[:id])
    raise ActiveRecord::RecordNotFound if @note.blank?

    if @note.update(update_params)
      render json: { validation_status: true, note: @note }, status: :ok
      return
    else
      error_messages = @note.errors.full_messages.join(', ')
      render json: { validation_status: false, error_message: error_messages },
             status: :unprocessable_entity
      return
    end
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

  def associate_with_category
    todo = Todo.find(params[:todo_id])
    category = Category.find(params[:category_id])
    TodoCategory.create!(todo: todo, category: category)
    render json: { message: 'Todo successfully associated with category' }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
  end

  private

  def create_params
    params.require(:notes).permit(:title, :description)
  end

  def update_params
    params.require(:notes).permit(:title, :description)
  end
end
