require 'swagger_helper'

RSpec.describe 'Note', type: :request do
  # jitera-hook-for-rswag-example
  path '/api/notes/{id}' do
    delete 'Destroy notes' do
      tags 'notes'
      consumes 'application/json'
      security [bearerAuth: []]

      parameter name: 'id', in: :path, type: :string, description: 'Url Params'

      response '200', 'delete' do
        examples 'application/json' => {

          'message' => {}

        }

        let(:resource) { create(:note) }
        let(:id) { resource.id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end

  path '/api/notes/{id}' do
    put 'Update  notes' do
      tags 'notes'
      consumes 'application/json'
      security [bearerAuth: []]

      parameter name: 'id', in: :path, type: :string, description: 'Url Params'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {

          notes: {
            type: :object,
            properties: {

              title: {

                type: :string

              },

              description: {

                type: :text

              }

            }
          }

        }
      }
      response '200', 'update' do
        examples 'application/json' => {

          'note' => {

            'id' => 'INTEGER',

            'created_at' => 'DATETIME',

            'updated_at' => 'DATETIME',

            'title' => 'STRING',

            'description' => 'TEXT'

          },

          'error_object' => {}

        }

        let(:resource) { create(:note) }

        let(:params) { { notes: resource.attributes.to_hash } }

        let(:id) { resource.id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end
  path '/api/notes/{id}' do
    get 'Show notes' do
      tags 'notes'
      consumes 'application/json'
      security [bearerAuth: []]

      parameter name: 'id', in: :path, type: :string, description: 'Url Params'

      response '200', 'show' do
        examples 'application/json' => {

          'note' => {

            'id' => 'INTEGER',

            'created_at' => 'DATETIME',

            'updated_at' => 'DATETIME',

            'title' => 'STRING',

            'description' => 'TEXT'

          },

          'message' => {}

        }

        let(:resource) { create(:note) }
        let(:id) { resource.id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end

  path '/api/notes' do
    post 'Create notes' do
      tags 'notes'
      consumes 'application/json'
      security [bearerAuth: []]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {

          notes: {
            type: :object,
            properties: {

              title: {

                type: :string

              },

              description: {

                type: :text

              }

            }
          }

        }
      }
      response '200', 'create' do
        examples 'application/json' => {

          'note' => {

            'id' => 'INTEGER',

            'created_at' => 'DATETIME',

            'updated_at' => 'DATETIME',

            'title' => 'STRING',

            'description' => 'TEXT'

          },

          'error_object' => {}

        }

        let(:resource) { build(:note) }

        let(:params) { { notes: resource.attributes.to_hash } }

        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end

  path '/api/notes' do
    get 'List notes' do
      tags 'notes'
      consumes 'application/json'
      security [bearerAuth: []]

      parameter name: :params, in: :url, schema: {
        type: :object,
        properties: {

          pagination_page: {

            type: :page_number

          },

          pagination_limit: {

            type: :page_size

          },

          notes: {
            type: :object,
            properties: {

              title: {

                type: :string

              },

              description: {

                type: :text

              }

            }
          }

        }
      }
      response '200', 'filter' do
        examples 'application/json' => {

          'total_pages' => 'INTEGER',

          'notes' => 'ARRAY',

          'message' => {}

        }

        let(:resource) { create(:note) }
        let(:params) {}
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
