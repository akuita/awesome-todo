
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
    post 'users_verify_confirmation_token/confirm/:token', to: 'users_verify_confirmation_token#confirm'

    resources :users_passwords, only: [:create] do
    end

    resources :users_registrations, only: [:create] do
    end
    get 'users/registrations/check_email', to: 'users_registrations#check_email_availability'

    resources :users_verify_reset_password_requests, only: [:create] do
    end

    resources :users_reset_password_requests, only: [:create] do
    end

    # The new route for email confirmation is correctly placed under the 'api' namespace
    get '/users/confirm-email/:token', to: 'users#confirm_email'

    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
