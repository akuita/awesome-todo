
json.access_token @access_token

json.token_type @token_type

json.expires_in @expires_in

json.refresh_token @refresh_token

json.scope @scope

json.created_at @created_at

json.resource_owner @resource_owner

json.resource_id @resource_id

if @user
  if @user.email_confirmed
    json.message I18n.t('devise.email_confirmation_success')
    json.email_confirmed @user.email_confirmed
  else
    json.error @error_message
  end
end
