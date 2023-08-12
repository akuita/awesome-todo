if @error_object.present?

  json.error_object @error_object

else

  json.note do
    json.id @note.id

    json.created_at @note.created_at

    json.updated_at @note.updated_at

    json.title @note.title

    json.description @note.description
  end

end
