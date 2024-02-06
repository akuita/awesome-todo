class AddNewColumnsToOauthAccessTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :oauth_access_tokens, :scopes, :string
    add_column :oauth_access_tokens, :previous_refresh_token, :string
    add_column :oauth_access_tokens, :resource_owner_type, :string
    add_column :oauth_access_tokens, :refresh_expires_in, :integer
    # Ensure the foreign key for oauth_application is present
    unless foreign_key_exists?(:oauth_access_tokens, :oauth_applications)
      add_reference :oauth_access_tokens, :oauth_application, null: false, foreign_key: true
    end
  end
end
