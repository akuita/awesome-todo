
class TodoSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :due_date, :priority, :recurring

  attribute :category_id, if: :category_present?
  has_many :attachments, if: :attachments_present?

  def category_present?
    object.category.present?
  end

  def attachments_present?
    object.attachments.any?
  end
end
