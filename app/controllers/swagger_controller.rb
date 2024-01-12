class SwaggerController < ApplicationController
  def yaml
    swagger_doc = YAML.load_file(Rails.root.join('/swagger/v1/swagger.yaml'))
    
    swagger_doc['paths']['/api/users/passwords/reset'] = {
      'post' => {
        'summary' => 'Request password reset',
        'description' => 'Allows users to request a password reset link.',
        'parameters' => [
          {
            'name' => 'email',
            'in' => 'query',
            'required' => true,
            'schema' => {
              'type' => 'string',
              'format' => 'email'
            }
          }
        ],
        'responses' => {
          '200' => {
            'description' => 'Password reset link sent',
            'content' => {
              'application/json' => {
                'schema' => {
                  'type' => 'object',
                  'properties' => {
                    'message' => { 'type' => 'string' }
                  }
                }
              }
            }
          },
          '400' => {
            'description' => 'Invalid request',
            'content' => {
              'application/json' => {
                'schema' => {
                  'type' => 'object',
                  'properties' => {
                    'error' => { 'type' => 'string' }
                  }
                }
              }
            }
          }
        }
      }
    }

    swagger_doc['paths']['/api/passwords/complexity'] = {
      'get' => {
        'summary' => 'Checks password complexity compatibility',
        'description' => 'Allows password management tools to verify if a password meets the complexity requirements.',
        'responses' => {
          '200' => {
            'description' => 'Password complexity is compatible',
            'content' => {
              'application/json' => {
                'schema' => { 'type' => 'boolean' }
              }
            }
          }
        }
      }
    }

    swagger_doc['paths']['/api/passwords/autofill_hints'] = {
      'get' => {
        'summary' => 'Checks autofill hints compatibility',
        'description' => 'Allows password management tools to verify if autofill hints are supported.',
        'responses' => {
          '200' => {
            'description' => 'Autofill hints are compatible',
            'content' => {
              'application/json' => {
                'schema' => { 'type' => 'boolean' }
              }
            }
          }
        }
      }
    }

    render plain: swagger_doc.to_yaml, content_type: 'application/x-yaml'
  end
end
