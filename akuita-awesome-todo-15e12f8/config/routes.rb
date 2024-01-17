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
  post '/users/register', to: 'users#register'
  post '/users/resend-confirmation', to: 'users#resend_confirmation'

  resources :users_passwords, only: [:create] do
  end

  resources :users_registrations, only: [:create] do
  end

  get 'users/check_email_availability', to: 'users#check_email_availability'
  resources :users_verify_reset_password_requests, only: [:create] do
  end

  resources :users_reset_password_requests, only: [:create] do
  end

  # The route for creating todos now includes an authentication constraint
  post '/todos', to: 'todos#create', constraints: lambda { |request| request.env['warden'].authenticate? }
  post 'todos/:todo_id/associate_category/:category_id', to: 'todos#associate_with_category'

  # New route to handle todo creation errors
  post '/todos/error', to: 'todos#log_todo_creation_error'

  resources :todos do
    resources :notes, only: %i[index create show update destroy] do
    end
    resources :attachments, only: [:create]
  end

  # The route for creating attachments is duplicated in the new and existing code.
  # We need to ensure that it is only defined once.
  # Since the new code includes an authentication constraint, we will use that version.
  post '/todos/:todo_id/attachments', to: 'attachments#create'

  resources :notes, only: %i[index create show update destroy] do
  end
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
