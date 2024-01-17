class TodoCategorySerializer < ActiveModel::Serializer
  attributes :id, :todo_id, :category_id, :created_at

  def created_at
    object.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ') # ISO8601 format
  end
end
