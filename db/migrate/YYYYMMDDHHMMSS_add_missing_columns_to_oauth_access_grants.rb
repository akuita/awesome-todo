class AddMissingColumnsToOauthAccessGrants < ActiveRecord::Migration[6.0]
  def change
    add_column :oauth_access_grants, :expires_in, :integer
    add_column :oauth_access_grants, :redirect_uri, :string
    add_column :oauth_access_grants, :revoked_at, :datetime
    add_column :oauth_access_grants, :scopes, :string
    add_column :oauth_access_grants, :resource_owner_type, :string

    # Ensure the oauth_application_id column is correctly defined
    unless column_exists? :oauth_access_grants, :oauth_application_id
      add_reference :oauth_access_grants, :oauth_application, null: false, foreign_key: true
    end
  end
end
