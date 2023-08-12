# rubocop:disable Style/ClassAndModuleChildren
class NoteService::Index
  attr_accessor :params, :records, :query

  def initialize(params, _current_user = nil)
    @params = params

    @records = Note
  end

  def execute
    title_start_with

    description_start_with

    order

    paginate
  end

  def title_start_with
    return if params.dig(:notes, :title).blank?

    @records = Note.where('title like ?', "%#{params.dig(:notes, :title)}")
  end

  def description_start_with
    return if params.dig(:notes, :description).blank?

    @records = if records.is_a?(Class)
                 Note.where(value.query)
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
end
# rubocop:enable Style/ClassAndModuleChildren
