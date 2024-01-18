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
  post '/users/validate-email', to: 'users#validate_email'

  resources :users_passwords, only: [:create] do
  end

  resources :users_registrations, only: [:create] do
  end

  get 'users/check_email_availability', to: 'users#check_email_availability'
  resources :users_verify_reset_password_requests, only: [:create] do
  end

  resources :users_reset_password_requests, only: [:create] do
  end

  post '/todos', to: 'todos#create', constraints: lambda { |request| request.env['warden'].authenticate? }
  post 'todos/:todo_id/associate_category/:category_id', to: 'todos#associate_with_category'
  post '/todos/validate', to: 'todos#validate'
  post '/todos/error', to: 'todos#log_todo_creation_error'

  post '/todo_categories', to: 'todo_categories#create'
  post '/todos/:todo_id/categories/:category_id', to: 'todo_categories#create' # Preserved from existing code
  post '/attachments', to: 'attachments#create'
  post '/notes', to: 'notes#create'

  resources :todos do
    resources :notes, only: %i[index create show update destroy] do
    end
    resources :attachments, only: [:create]
  end

  resources :notes, only: %i[index create show update destroy] do
  end

  post '/todos/:todo_id/attachments', to: 'attachments#create' # Preserved from existing code
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
