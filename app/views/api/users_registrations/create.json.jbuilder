json.id @id
json.status @status
json.message do
  json.array!(@messages) unless @messages.blank?
end
