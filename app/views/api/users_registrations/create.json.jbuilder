json.status 201
json.message "User registered successfully. Please check your email to verify your account."
json.user do
  json.id @user.id
  json.username @user.username
  json.email @user.email
  json.created_at @user.created_at.iso8601
end
