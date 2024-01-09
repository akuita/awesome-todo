require 'sidekiq/web'

Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  devise_for :users
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    resources :users_verify_confirmation_token, only: [:create] do
    end

    # The new code does not have the custom route for user registration, so we keep the existing one.
    post '/users/register', to: 'users_registrations#register'

    resources :users_registrations, only: [:create] do
    end

    resources :users_passwords, only: [:create] do
    end

    resources :users_verify_reset_password_requests, only: [:create] do
    end

    resources :users_reset_password_requests, only: [:create] do
    end

    # Integrating the new route for password management tool integration
    post '/users/:user_id/password_management_tools/:tool_id/integrate', to: 'users_registrations#integrate_password_management_tool'

    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
