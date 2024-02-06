json.status 201
json.error do
  json.id @error.id
  json.project_id @error.project_id
  json.message @error.message
  json.timestamp @error.timestamp.iso8601
end
