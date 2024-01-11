
# config/initializers/doorkeeper.rb

# Other configurations above this line...

# custom_access_token_expires_in do |context|
#   # Define custom logic for access token expiration here
# end
custom_access_token_expires_in do |context|
  # Set to 12 hours to provide a longer life span for tokens used by password management tools
  12.hours
end

# Other configurations...

# reuse_access_token
reuse_access_token # Enable token reuse to reduce the number of tokens generated for password management tools

# Other configurations...

# token_reuse_limit 100
token_reuse_limit 90 # Set a reuse limit to 90% to ensure tokens are refreshed before completely expiring

# Other configurations...

# use_refresh_token
use_refresh_token # Ensure refresh tokens are issued to support password management tools

# Other configurations...

# enable_application_owner confirmation: true

# Other configurations below this line...
