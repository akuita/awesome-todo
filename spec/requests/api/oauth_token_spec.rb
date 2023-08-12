# frozen_string_literal: true

require 'swagger_helper'

describe 'Oauth Token API' do
  path '/oauth/token' do
    post 'Oauth Token' do
      tags 'Login - Oauth Token(Common Login)'
      consumes 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          client_id: { type: :string, example: Doorkeeper::Application.find_by(scopes: 'users')&.uid.to_s },
          client_secret: { type: :string, example: Doorkeeper::Application.find_by(scopes: 'users')&.secret.to_s },
          password: { type: :string, example: 'password' },
          email: { type: :string, example: 'email@domaiin.com' },
          scope: { type: :string, example: 'users any one based on login needed' },
          grant_type: { type: :string, example: 'password refresh_token anyone' },
          refresh_token: { type: :string, example: 'token if grant type refresh' }
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
        let(:password) { 'JiteraPassword@1234' }
        let(:resource) { create(:users, password: password) }
        let(:email) { resource.email }
        before do
          resource.confirm if resource.respond_to?(:confirm)
        end

        let(:params) do
          {
            password: password,
            email: email,
            scope: :users,
            grant_type: :password,
            client_id: doorkeeper_application.uid,
            client_secret: doorkeeper_application.secret
          }
        end

        run_test! do |response|
          expect(response.status).to eql(200)
        end
      end
    end
  end
end
