
json.access_token @access_token

json.token_type @token_type

json.expires_in @expires_in

json.refresh_token @refresh_token

json.scope @scope

json.created_at @created_at

json.resource_owner @resource_owner

json.resource_id @resource_id

json.set! :success_message, I18n.t('common.email_confirmed')
json.user do
  json.email @user.email
  json.email_confirmed @user.email_confirmed
end
