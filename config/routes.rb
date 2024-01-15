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

    # The new code has a different route for users/verify_confirmation_token, but since it's the same action, we can ignore the new route.
    # post 'users/verify_confirmation_token', to: 'users_verify_confirmation_token#create', as: 'verify_confirmation_token'

    resources :users_passwords, only: [:create] do
    end

    resources :users_registrations, only: [:create] do
    end

    # The existing code has an additional route for checking email availability, which should be preserved.
    get 'users_registrations/check_email_availability', to: 'users_registrations#check_email_availability', as: 'check_email'

    # The new code does not have the post '/users', to: 'users_registrations#create' route, but we should keep it as it's part of the existing functionality.
    post '/users', to: 'users_registrations#create'

    resources :users_verify_reset_password_requests, only: [:create] do
    end

    resources :users_reset_password_requests, only: [:create] do
    end

    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
