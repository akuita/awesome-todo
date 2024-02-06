json.status 201
json.project do
  json.id @project.id
  json.name @project.name
  json.user_id @project.user_id
  json.created_at @project.created_at.iso8601
end
