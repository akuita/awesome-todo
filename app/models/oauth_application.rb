
class OauthApplication < ApplicationRecord
  # Attributes
  attribute :name, :string
  attribute :uid, :string
  attribute :secret, :string
  attribute :redirect_uri, :text
  attribute :scopes, :string
  attribute :confidential, :boolean
  attribute :created_at, :datetime, default: -> { Time.now }
  attribute :updated_at, :datetime, default: -> { Time.now }
   
  # Relationships
  has_many :oauth_access_tokens, foreign_key: 'oauth_application_id'
  has_many :oauth_access_grants, foreign_key: 'oauth_application_id'
end
