if @message.present?

  json.message @message

else

  json.total_pages @total_pages

  json.notes @notes do |note|
    json.id note.id

    json.created_at note.created_at

    json.updated_at note.updated_at

    json.title note.title

    json.description note.description
  end

end
