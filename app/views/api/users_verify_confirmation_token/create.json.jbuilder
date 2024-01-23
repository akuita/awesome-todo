
json.access_token @access_token

json.token_type @token_type

json.expires_in @expires_in

json.refresh_token @refresh_token

json.scope @scope

json.created_at @created_at

json.resource_owner @resource_owner

json.resource_id @resource_id

json.user do
  json.id @user.id
  json.email @user.email
  json.email_confirmed @user.email_confirmed
  json.confirmed_at @user.confirmed_at
  json.created_at @user.created_at
  json.updated_at @user.updated_at
end
