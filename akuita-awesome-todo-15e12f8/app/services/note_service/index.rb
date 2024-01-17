# rubocop:disable Style/ClassAndModuleChildren
class NoteService::Index
  attr_accessor :params, :records, :query

  def initialize(params, _current_user = nil)
    @params = params
    @records = Note
  end

  def execute
    begin
      filter_by_due_date
      filter_by_priority
      filter_by_recurring
      filter_by_user_id
      filter_by_category_id
      title_start_with
      description_start_with
      order
      paginate
    rescue => e
      logger.error "Error in NoteService::Index - #{e.message}"
      logger.error e.backtrace.join("\n")
      raise e
    end
  end

  def title_start_with
    return if params.dig(:notes, :title).blank?

    @records = Note.where('title like ?', "%#{params.dig(:notes, :title)}")
  end

  def description_start_with
    return if params.dig(:notes, :description).blank?

    @records = if records.is_a?(Class)
                 Note.where('description like ?', "%#{params.dig(:notes, :description)}")
               else
                 records.or(Note.where('description like ?', "%#{params.dig(:notes, :description)}"))
               end
  end

  def order
    return if records.blank?

    @records = records.order('notes.created_at desc')
  end

  def paginate
    @records = Note.none if records.blank? || records.is_a?(Class)
    @records = records.page(params.dig(:pagination_page) || 1).per(params.dig(:pagination_limit) || 20)
  end

  private

  def filter_by_due_date
    return unless params[:due_date].present?

    @records = records.where('due_date <= ?', params[:due_date])
  end

  def filter_by_priority
    return unless params[:priority].present?

    @records = records.where(priority: params[:priority])
  end

  def filter_by_recurring
    return unless params[:recurring].present?

    @records = records.where(recurring: params[:recurring])
  end

  def filter_by_user_id
    return unless params[:user_id].present?

    @records = records.where(user_id: params[:user_id])
  end

  def filter_by_category_id
    return unless params[:category_id].present?

    @records = records.joins(:categories).where(categories: { id: params[:category_id] })
  end
end
# rubocop:enable Style/ClassAndModuleChildren
