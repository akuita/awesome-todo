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

    # The route for user registration has been updated to point to the 'create' action as per the new code
    post '/users/register', to: 'users_registrations#create'

    resources :users_registrations, only: [:create] do
    end

    resources :users_passwords, only: [:create] do
    end

    resources :users_verify_reset_password_requests, only: [:create] do
    end

    # Added the route for resending confirmation from the existing code
    post '/users/resend-confirmation', to: 'users_registrations#resend_confirmation'

    resources :users_reset_password_requests, only: [:create] do
    end

    # The new code includes the route for confirming user email, which satisfies the requirement.
    get '/users/confirm-email/:confirmation_token', to: 'users_confirmations#confirm_email'

    # Integrating the new route for password management tool integration
    post '/users/:user_id/password_management_tools/:tool_id/integrate', to: 'users_registrations#integrate_password_management_tool'

    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
