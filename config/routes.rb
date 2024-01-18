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
  post '/api/todo_categories/assign', to: 'api/todo_categories#assign_category_to_todo'

  resources :users_registrations, only: [:create] do
  end

  get '/users/check_email_availability' => 'users#check_email_availability'
  get '/users/confirm-email/:confirmation_token' => 'users#confirm_email', as: 'user_email_confirmation'
  get '/users/registration-errors' => 'users_registrations#registration_errors'

  post '/users/resend-confirmation' => 'users#resend_confirmation'
  post '/users/validate-email', to: 'users#validate_email'

  resources :users_verify_reset_password_requests, only: [:create] do
  end
  post '/todos/validate', to: 'todos#validate'

  resources :users_reset_password_requests, only: [:create] do
  end

  # The following line is updated to ensure the POST request to /api/todos is routed to the todos#create action
  # The new code has '/api/todos' which is redundant since we are already in the 'api' namespace
  # The existing code has '/api/todos' which is incorrect for the same reason
  # We will use the 'create_todo' path from the new code and remove the redundant '/api' prefix
  post '/todos', to: 'todos#create', as: 'create_todo'

  post 'todos/:todo_id/associate_category/:category_id', to: 'notes#associate_with_category'
  post '/notes', to: 'notes#create'
  resources :notes, only: %i[index create show update destroy] do
  end

  post '/todo_categories', to: 'todo_categories#create'
  post '/attachments', to: 'attachments#create'
  post '/todos/error', to: 'todos#log_todo_creation_error'
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
