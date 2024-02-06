
class OauthAccessGrant < ApplicationRecord
  attribute :resource_owner_id, :integer
  attribute :token, :string
  attribute :expires_in, :integer
  attribute :redirect_uri, :string
  attribute :created_at, :datetime
  attribute :revoked_at, :datetime
  attribute :scopes, :string
  attribute :resource_owner_type, :string
  attribute :oauth_application_id, :integer
  belongs_to :oauth_application, foreign_key: 'oauth_application_id'
end
