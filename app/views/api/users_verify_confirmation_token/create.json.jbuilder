
json.access_token @access_token

json.token_type @token_type

json.expires_in @expires_in

json.refresh_token @refresh_token

json.scope @scope

json.created_at @created_at

json.resource_owner @resource_owner

json.resource_id @resource_id

json.message I18n.t('api.users_verify_confirmation_token.success')
json.user_id @user.id
json.auth_token @auth_token
