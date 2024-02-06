
class OauthAccessToken < ApplicationRecord
  attribute :resource_owner_id, :integer
  attribute :token, :string
  attribute :refresh_token, :string
  attribute :expires_in, :integer
  attribute :revoked_at, :datetime
  attribute :created_at, :datetime
  attribute :scopes, :string
  attribute :previous_refresh_token, :string
  attribute :resource_owner_type, :string
  attribute :refresh_expires_in, :integer
  belongs_to :oauth_application, foreign_key: 'oauth_application_id'
end
