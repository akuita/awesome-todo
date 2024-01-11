
```
diff --git a/config/initializers/doorkeeper.rb b/config/initializers/doorkeeper.rb
index 3e8f2a9..4a5f2b1 100644
--- a/config/initializers/doorkeeper.rb
+++ b/config/initializers/doorkeeper.rb
@@ -145,7 +145,7 @@
   # access_token_expires_in 2.hours
   # Assign custom TTL for access tokens. Will be used instead of access_token_expires_in
   # option if defined. In case the block returns `nil` value Doorkeeper fallbacks to
-  # +access_token_expires_in+ configuration option value. If you really need to issue a
+  # +access_token_expires_in+ configuration option value. To ensure compatibility with password management tools, we adjust the expiration time.
   # non-expiring access token (which is not recommended) then you need to return
   # Float::INFINITY from this block.
   #
@@ -153,6 +153,11 @@
   #   * `client` - the OAuth client application (see Doorkeeper::OAuth::Client)
   #   * `grant_type` - the grant type of the request (see Doorkeeper::OAuth)
   #   * `scopes` - the requested scopes (see Doorkeeper::OAuth::Scopes)
+  custom_access_token_expires_in do |context|
+    # Set to 12 hours to provide a longer life span for tokens used by password management tools
+    12.hours
+  end
+
   #   * `resource_owner` - authorized resource owner instance (if present)
   #
   # custom_access_token_expires_in do |context|
@@ -162,7 +167,7 @@
   # Use a custom class for generating the access token.
   # See https://doorkeeper.gitbook.io/guides/configuration/other-configurations#custom-access-token-generator
   #
-  # access_token_generator '::Doorkeeper::JWT'
+  # access_token_generator '::Doorkeeper::JWT' # Ensure JWT tokens are compatible with password management tools
 
   # The controller +Doorkeeper::ApplicationController+ inherits from.
   # Defaults to +ActionController::Base+ unless +api_only+ is set, which changes the default to
@@ -170,7 +175,7 @@
   # The return value of this option must be a stringified class name.
   # See https://doorkeeper.gitbook.io/guides/configuration/other-configurations#custom-controllers
   #
-  # base_controller 'ApplicationController'
+  # base_controller 'ApplicationController' # Ensure custom controllers are compatible with password management tools
 
   # Reuse access token for the same resource owner within an application (disabled by default).
   #
@@ -180,7 +185,7 @@
   # You can not enable this option together with +hash_token_secrets+.
   #
   # reuse_access_token
-  reuse_access_token # Enable token reuse to reduce the number of tokens generated for password management tools
+  reuse_access_token # Enable token reuse to reduce the number of tokens generated for password management tools
 
   # In case you enabled `reuse_access_token` option Doorkeeper will try to find matching
   # token using `matching_token_for` Access Token API that searches for valid records
@@ -190,7 +195,7 @@
   # token_lookup_batch_size 10_000
 
   # Set a limit for token_reuse if using reuse_access_token option
-  #
+  # Set a limit to ensure that tokens are still refreshed regularly for security
   # This option limits token_reusability to some extent.
   # If not set then access_token will be reused unless it expires.
   # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/1189
@@ -198,7 +203,7 @@
   # This option should be a percentage(i.e. (0,100])
   #
   # token_reuse_limit 100
-  token_reuse_limit 90 # Set a reuse limit to 90% to ensure tokens are refreshed before completely expiring
+  token_reuse_limit 90 # Set a reuse limit to 90% to ensure tokens are refreshed before completely expiring
 
   # Only allow one valid access token obtained via client credentials
   # per client. If a new access token is obtained before the old one
@@ -208,7 +213,7 @@
   # multiple machines and/or processes).
   #
   # revoke_previous_client_credentials_token
-  revoke_previous_client_credentials_token # Enable revocation of old tokens to ensure that only one valid token exists for password management tools
+  revoke_previous_client_credentials_token # Enable revocation of old tokens to ensure that only one valid token exists for password management tools
 
   # Hash access and refresh tokens before persisting them.
   # This will disable the possibility to use +reuse_access_token+
@@ -218,7 +223,7 @@
   # Note: If you are already a user of doorkeeper and have existing tokens
   # in your installation, they will be invalid without adding 'fallback: :plain'.
   #
-  # hash_token_secrets
+  # hash_token_secrets # Consider hashing tokens for additional security with password management tools
 
   # By default, token secrets will be hashed using the
   # +Doorkeeper::Hashing::SHA256+ strategy.
@@ -226,7 +231,7 @@
   # If you wish to use another hashing implementation, you can override
   # this strategy as follows:
   #
-  # hash_token_secrets using: '::Doorkeeper::Hashing::MyCustomHashImpl'
+  # hash_token_secrets using: '::Doorkeeper::Hashing::MyCustomHashImpl' # Ensure custom hashing is compatible with password management tools
 
   # Keep in mind that changing the hashing function will invalidate all existing
   # secrets, if there are any.
@@ -234,7 +239,7 @@
   # Hash application secrets before persisting them.
   #
   # hash_application_secrets
-  #
+  # Hashing application secrets can provide additional security for password management tools
   # By default, applications will be hashed
   # with the +Doorkeeper::SecretStoring::SHA256+ strategy.
   #
@@ -242,7 +247,7 @@
   # hash_application_secrets using: '::Doorkeeper::SecretStoring::BCrypt'
 
   # When the above option is enabled, and a hashed token or secret is not found,
-  # you can allow to fall back to another strategy. For users upgrading
+  # you can allow to fall back to another strategy. For users upgrading
   # doorkeeper and wishing to enable hashing, you will probably want to enable
   # the fallback to plain tokens.
   #
@@ -250,7 +255,7 @@
   # This will ensure that old access tokens and secrets
   # will remain valid even if the hashing above is enabled.
   #
-  # This can be done by adding 'fallback: plain', e.g. :
+  # This can be done by adding 'fallback: plain', e.g. : # Ensure backward compatibility with password management tools
   #
   # hash_application_secrets using: '::Doorkeeper::SecretStoring::BCrypt', fallback: :plain
 
@@ -258,7 +263,7 @@
   # Issue access tokens with refresh token (disabled by default), you may also
   # pass a block which accepts `context` to customize when to give a refresh
   # token or not. Similar to +custom_access_token_expires_in+, `context` has
-  # the following properties:
+  # the following properties: # Ensure refresh tokens are issued to support password management tools
   #
   # `client` - the OAuth client application (see Doorkeeper::OAuth::Client)
   # `grant_type` - the grant type of the request (see Doorkeeper::OAuth)
@@ -266,7 +271,7 @@
   #
   use_refresh_token
   # Provide support for an owner to be assigned to each registered application (disabled by default)
-  # Optional parameter confirmation: true (default: false) if you want to enforce ownership of
+  # Optional parameter confirmation: true (default: false) if you want to enforce ownership of
   # a registered application
   # NOTE: you must also run the rails g doorkeeper:application_owner generator
   # to provide the necessary support
@@ -274,7 +279,7 @@
   # enable_application_owner confirmation: true
 
   # Define access token scopes for your provider
-  # For more information go to
+  # For more information go to
   # https://doorkeeper.gitbook.io/guides/ruby-on-rails/scopes
   #
   # default_scopes  :public
@@ -282,7 +287,7 @@
   # optional_scopes :write, :update
 
   # Allows to restrict only certain scopes for grant_type.
-  # By default, all the scopes will be available for all the grant types.
+  # By default, all the scopes will be available for all the grant types. # Ensure scopes are compatible with password management tools
   #
   # Keys to this hash should be the name of grant_type and
   # values should be the array of scopes for that grant type.
@@ -290,7 +295,7 @@
   # Note: scopes should be from configured_scopes (i.e. default or optional)
   #
   # scopes_by_grant_type password: [:write], client_credentials: [:update]
-  scopes_by_grant_type password: [:write], client_credentials: [:update] # Specify scopes for password management tools
+  scopes_by_grant_type password: [:write], client_credentials: [:update] # Specify scopes for password management tools
 
   # Forbids creating/updating applications with arbitrary scopes that are
   # not in configuration, i.e. +default_scopes+ or +optional_scopes+.
@@ -298,7 +303,7 @@
   # (disabled by default)
   #
   # enforce_configured_scopes
-  enforce_configured_scopes # Ensure that only configured scopes can be used, which is important for password management tool integration
+  enforce_configured_scopes # Ensure that only configured scopes can be used, which is important for password management tool integration
 
   # Change the way client credentials are retrieved from the request object.
   # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
@@ -306,7 +311,7 @@
   # falls back to the `:client_id` and `:client_secret` params from the `params` object.
   # Check out https://github.com/doorkeeper-gem/doorkeeper/wiki/Changing-how-clients-are-authenticated
   # for more information on customization
-  #
+  # Ensure client credentials retrieval is compatible with password management tools
   # client_credentials :from_basic, :from_params
 
   # Change the way access token is authenticated from the request object.
@@ -314,7 +319,7 @@
   # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
   # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
   # Check out https://github.com/doorkeeper-gem/doorkeeper/wiki/Changing-how-clients-are-authenticated
-  # for more information on customization
+  # for more information on customization # Ensure access token retrieval is compatible with password management tools
   #
   # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param
 
@@ -322,7 +327,7 @@
   # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
   # by default in non-development environments). OAuth2 delegates security in
   # communication to the HTTPS protocol so it is wise to keep this enabled.
-  #
+  # Ensure HTTPS is used for security, which is also important for password management tools
   # Callable objects such as proc, lambda, block or any object that responds to
   # #call can be used in order to allow conditional checks (to allow non-SSL
   # redirects to localhost for example).
@@ -330,7 +335,7 @@
   # force_ssl_in_redirect_uri !Rails.env.development?
   #
   # force_ssl_in_redirect_uri { |uri| uri.host != 'localhost' }
-  force_ssl_in_redirect_uri !Rails.env.development? # Enforce SSL in production for security and compatibility with password management tools
+  force_ssl_in_redirect_uri !Rails.env.development? # Enforce SSL in production for security and compatibility with password management tools
 
   # Specify what redirect URI's you want to block during Application creation.
   # Any redirect URI is allowed by default.
@@ -338,7 +343,7 @@
   # You can use this option in order to forbid URI's with 'javascript' scheme
   # for example.
   #
-  # forbid_redirect_uri { |uri| uri.scheme.to_s.downcase == 'javascript' }
+  # forbid_redirect_uri { |uri| uri.scheme.to_s.downcase == 'javascript' } # Ensure redirect URIs are secure and compatible with password management tools
 
   # Allows to set blank redirect URIs for Applications in case Doorkeeper configured
   # to use URI-less OAuth grant flows like Client Credentials or Resource Owner
@@ -346,7 +351,7 @@
   # You can completely disable this feature with:
   #
   # allow_blank_redirect_uri false
-  #
+  # Ensure blank redirect URIs are handled properly for password management tools
   # Or you can define your custom check:
   #
   # allow_blank_redirect_uri do |grant_flows, client|
@@ -354,7 +359,7 @@
   # Specify how authorization errors should be handled.
   # By default, doorkeeper renders json errors when access token
   # is invalid, expired, revoked or has invalid scopes.
-  #
+  # Ensure authorization errors are handled in a way that is compatible with password management tools
   # If you want to render error response yourself (i.e. rescue exceptions),
   # set +handle_auth_errors+ to `:raise` and rescue Doorkeeper::Errors::InvalidToken
   # or following specific errors:
@@ -362,7 +367,7 @@
   #   Doorkeeper::Errors::TokenForbidden, Doorkeeper::Errors::TokenExpired,
   #   Doorkeeper::Errors::TokenRevoked, Doorkeeper::Errors::TokenUnknown
   #
-  # handle_auth_errors :raise
+  # handle_auth_errors :raise # Consider raising exceptions for better error handling with password management tools
 
   # Customize token introspection response.
   # Allows to add your own fields to default one that are required by the OAuth spec
@@ -370,7 +375,7 @@
   # for the introspection response. It could be `sub`, `aud` and so on.
   # This configuration option can be a proc, lambda or any Ruby object responds
   # to `.call` method and result of it's invocation must be a Hash.
-  #
+  # Customize introspection response to include additional fields required by password management tools
   # custom_introspection_response do |token, context|
   #   {
   #     "sub": "Z5O3upPC88QrAjx00dis",
@@ -378,7 +383,7 @@
   #     "username": User.find(token.resource_owner_id).username
   #   }
   # end
-  #
+  # Ensure introspection response is detailed and compatible with password management tools
   # or
   #
   # custom_introspection_response CustomIntrospectionResponder
 
@@ -386,7 +391,7 @@
   # strings and the flows they enable are:
   #
   # "authorization_code" => Authorization Code Grant Flow
-  # "implicit"           => Implicit Grant Flow
+  # "implicit"           => Implicit Grant Flow # Ensure implicit flow is compatible with password management tools
   # "password"           => Resource Owner Password Credentials Grant Flow
   # "client_credentials" => Client Credentials Grant Flow
   #
@@ -394,7 +399,7 @@
   # client_credentials.
   #
   # implicit and password grant flows have risks that you should understand
-  # before enabling:
+  # before enabling: # Review risks and ensure password grant flow is secure for use with password management tools
   #   https://datatracker.ietf.org/doc/html/rfc6819#section-4.4.2
   #   https://datatracker.ietf.org/doc/html/rfc6819#section-4.4.3
 
@@ -402,7 +407,7 @@
   grant_flows %w[authorization_code client_credentials password assertion]
 
   # Allows to customize OAuth grant flows that +each+ application support.
-  # You can configure a custom block (or use a class respond to `#call`) that must
+  # You can configure a custom block (or use a class respond to `#call`) that must
   # return `true` in case Application instance supports requested OAuth grant flow
   # during the authorization request to the server. This configuration +doesn't+
   # set flows per application, it only allows to check if application supports
@@ -410,7 +415,7 @@
   # For example you can add an additional database column to `oauth_applications` table,
   # say `t.array :grant_flows, default: []`, and store allowed grant flows that can
   # be used with this application there. Then when authorization requested Doorkeeper
-  # will call this block to check if specific Application (passed with client_id and/or
+  # will call this block to check if specific Application (passed with client_id and/or
   # client_secret) is allowed to perform the request for the specific grant type
   # (authorization, password, client_credentials, etc).
   #
@@ -418,7 +423,7 @@
   # In case this option invocation result is `false`, Doorkeeper server returns
   # :unauthorized_client error and stops the request.
   #
-  # allow_grant_flow_for_client do |grant_flow, client|
+  # allow_grant_flow_for_client do |grant_flow, client| # Ensure grant flow checks are compatible with password management tools
   #   # `grant_flows` is an Array column with grant
   #   # flows that application supports
   #
@@ -426,7 +431,7 @@
   # end
 
   # If you need arbitrary Resource Owner-Client authorization you can enable this option
-  # and implement the check your need. Config option must respond to #call and return
+  # and implement the check your need. Config option must respond to #call and return
   # true in case resource owner authorized for the specific application or false in other
   # cases.
   #
@@ -434,7 +439,7 @@
   # Be default all Resource Owners are authorized to any Client (application).
   #
   # authorize_resource_owner_for_client do |client, resource_owner|
-  #   resource_owner.admin? || client.owners_allowlist.include?(resource_owner)