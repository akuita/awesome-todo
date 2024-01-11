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

    # Updated the route for user registration to match the requirement
    post '/users/register', to: 'users_registrations#create'

    resources :users_registrations, only: [:create] do
    end

    resources :users_passwords, only: [:create] do
    end

    resources :users_verify_reset_password_requests, only: [:create] do
    end

    post '/users/resend-confirmation', to: 'users_registrations#resend_confirmation'

    resources :users_reset_password_requests, only: [:create] do
    end

    # Merged the route for email confirmation with the alias from the existing code
    get '/users/confirm-email/:confirmation_token', to: 'users_confirmations#confirm_email', as: 'confirm_email'

    post '/users/:user_id/password_management_tools/:tool_id/integrate', to: 'users_registrations#integrate_password_management_tool'

    # Retained the route for checking email availability from the new code
    get 'users/check_email_availability', to: 'users_registrations#check_email_availability'

    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
