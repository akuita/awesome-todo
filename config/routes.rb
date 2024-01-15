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
  post '/users/confirm_email', to: 'users_verify_confirmation_token#create'
  post '/users/register' => 'users_registrations#register', as: 'user_registration'
  post '/users' => 'users_registrations#create'

  resources :users_passwords, only: [:create] do
  end

  resources :users_registrations, only: [:create] do
  end

  get '/users/check_email_availability' => 'users#check_email_availability'
  get '/users/confirm-email/:confirmation_token' => 'users#confirm_email', as: 'user_email_confirmation'
  get '/users/registration-errors' => 'users_registrations#registration_errors'

  # Merged the resend confirmation routes from new and existing code
  post '/users/resend-confirmation' => 'users#resend_confirmation'
  post '/users/resend_confirmation' => 'users_verify_confirmation_token#resend_confirmation'

  # Merged the validate email routes from new and existing code
  post '/users/validate-email', to: 'users#validate_email'

  resources :users_verify_reset_password_requests, only: [:create] do
  end

  resources :users_reset_password_requests, only: [:create] do
  end

  resources :notes, only: %i[index create show update destroy] do
  end
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
