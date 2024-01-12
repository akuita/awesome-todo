
use_doorkeeper do
  controllers tokens: 'tokens'
  skip_controllers :authorizations, :applications, :authorized_applications
end

devise_for :users
mount Rswag::Ui::Engine => '/api-docs'
mount Rswag::Api::Engine => '/api-docs'

post 'users/resend-confirmation', to: 'users#resend_confirmation'
# Ensure RESTful routes for password management
namespace :api do
  resources :users_verify_confirmation_token, only: [:create] do
  end
  post 'users/resend-confirmation', to: 'users_verify_confirmation_token#resend_confirmation'
  post 'users/confirmation', to: 'users_verify_confirmation_token#create'

  resources :users_passwords, only: [:create] do
  end

  # Documentation for password management endpoints
  get 'users_passwords/documentation', to: 'users_passwords#documentation'
  resources :users_registrations, only: [:create] do
  end
  get 'users/check_email', to: 'users_registrations#check_email_availability', as: 'check_email_availability'
  post 'users/register', to: 'users_registrations#create', as: 'user_registration'

  resources :users_verify_reset_password_requests, only: [:create] do
    # Endpoint to verify reset password requests
  end

  get 'users/confirm-email/:token', to: 'users#confirm_email', as: 'user_email_confirmation'
  post 'users/store-password', to: 'users#store_password', as: 'store_user_password', constraints: lambda { |req| req.env["warden"].authenticate? && req.env["warden"].user.admin? }

  resources :users_reset_password_requests, only: [:create] do
  end

  resources :notes, only: %i[index create show update destroy] do
    # RESTful routes for notes management
  end
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
