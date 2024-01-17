class TodoSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :due_date, :priority, :recurring
  has_many :categories, if: :categories_present?

  attribute :category_id, if: :category_present?
  has_many :attachments, if: :attachments_present?

  def category_present?
    object.category_id.present?
  end

  def categories_present?
    object.categories.any?
  end

  def attachments_present?
    object.attachments.any?
  end

  def category_id
    object.category_id
  end
end

