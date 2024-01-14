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
    # The new route for user registration is added and the old route is preserved
    post '/users/register' => 'users_registrations#register', as: 'user_registration'
    post '/users' => 'users_registrations#create'

    resources :users_passwords, only: [:create] do
    end

    resources :users_registrations, only: [:create] do
    end

    # The new route for email confirmation is correctly defined according to the requirement.
    get '/users/confirm-email/:confirmation_token' => 'users#confirm_email'
    # The route for registration errors is preserved from the new code
    get '/users/registration-errors' => 'users_registrations#registration_errors'

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
