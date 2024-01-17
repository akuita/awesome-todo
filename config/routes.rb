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
    # Added the missing route from the existing code for verifying confirmation token
    post 'users/verify_confirmation_token', to: 'users_verify_confirmation_token#verify'

    resources :users_passwords, only: [:create] do
    end

    resources :users_registrations, only: [:create] do
    end

    # New route for validating email format from the existing code
    post 'validate_email_format', to: 'users_registrations#validate_email_format'

    # Preserving the existing route for checking email availability
    get 'users_registrations/check_email_availability', to: 'users_registrations#check_email_availability', as: 'check_email'

    # Preserving the existing route for creating users
    post '/users', to: 'users_registrations#create'

    # Correcting the route for resending confirmation as per the requirement
    post 'users/resend-confirmation', to: 'users_registrations#resend_confirmation'

    # Route for confirming email with token from the existing code
    get 'users/confirm-email/:token', to: 'users#confirm_email'

    # The new route for user registration is added here as per the requirement
    # Removed the duplicate route for user registration
    post '/users/register', to: 'users_registrations#register'

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
