
json.access_token @access_token

json.token_type @token_type

json.expires_in @expires_in

json.refresh_token @refresh_token

json.scope @scope

json.created_at @created_at

json.resource_owner @resource_owner

json.resource_id @resource_id

if @confirmation_success
  json.message I18n.t('users_verify_confirmation_token.confirmation_success')
else
  json.error_message I18n.t('users_verify_confirmation_token.confirmation_failure')
end

json.user do
  json.email_confirmed @user.email_confirmed if @user.present?
end
