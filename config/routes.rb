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

  resources :users_passwords, only: [:create] do
  end

  resources :users_registrations, only: [:create] do
  end

  resources :users_verify_reset_password_requests, only: [:create] do
  end

  resources :users_reset_password_requests, only: [:create] do
  end

  post '/projects', to: 'projects#create', as: :create_project
  resources :notes, only: %i[index create show update destroy] do
  end

  post 'users/resend-confirmation', to: 'users_registrations#resend_confirmation_email'

  # New route for email confirmation
  get 'users/confirm_email/:confirmation_token', to: 'users#confirm_email', as: :confirm_email

  # Existing route for error reporting
  post 'errors', to: 'errors#create'
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
