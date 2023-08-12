require 'swagger_helper'

RSpec.describe 'User', type: :request do
  # jitera-hook-for-rswag-example
  path '/api/users_verify_confirmation_token' do
    post 'Verify confirmation token' do
      tags 'Email Login - users'
      consumes 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          confirmation_token: { type: :string, example: 'token' },
          client_id: { type: :string, example: Doorkeeper::Application.find_by(scopes: 'users')&.uid.to_s },
          client_secret: { type: :string, example: Doorkeeper::Application.find_by(scopes: 'users')&.secret.to_s }
        }
      }

      response '200', 'request sent' do
        examples 'application/json' => {

          'access_token' => 'STRING',

          'token_type' => 'STRING',

          'expires_in' => 'STRING',

          'refresh_token' => 'STRING',

          'scope' => 'STRING',

          'created_at' => 'STRING',

          'resource_owner' => 'STRING',

          'resource_id' => 'STRING'

        }
        let(:resource) { create(:user) }
        let(:client) { create(:application, scopes: :users) }

        before do
          resource.send_confirmation_instructions
        end

        let(:token) { resource.confirmation_token }
        let(:params) do
          {
            confirmation_token: token,
            client_id: client.uid.to_s,
            client_secret: client.secret.to_s
          }
        end

        run_test! do |response|
          expect(response.status).to eql(200)
        end
      end
    end
  end
end
