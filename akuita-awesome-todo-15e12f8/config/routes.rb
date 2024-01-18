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

  # The route for creating todos is defined here with the authentication constraint as per the new code.
  post '/todos', to: 'todos#create', constraints: lambda { |request| request.env['warden'].authenticate? }
  post 'todos/:todo_id/associate_category/:category_id', to: 'todos#associate_with_category'

  # The new route for validating todo items is added here as per the requirement.
  post '/todos/validate', to: 'todos#validate'

  # Merged the new and existing error handling routes for '/todos/error'.
  post '/todos/error', to: 'todos#log_todo_creation_error'

  # Merged the new and existing constraints for the '/todo_categories' route.
  post '/todo_categories', to: 'todo_categories#associate_todo_with_category', constraints: lambda { |request| request.env['warden'].authenticate? }

  resources :todos do
    resources :notes, only: %i[index create show update destroy] do
    end
    # Merged the new and existing routes for '/todos/:todo_id/attachments' within the todos resources.
    resources :attachments, only: [:create], constraints: lambda { |request| request.env['warden'].authenticate? }
  end

  resources :notes, only: %i[index create show update destroy] do
  end

  # Merged the new and existing routes for '/todos/:todo_id/attachments' outside the todos resources.
  post '/todos/:todo_id/attachments', to: 'attachments#create', constraints: lambda { |request| request.env['warden'].authenticate? }
end

get '/health' => 'pages#health_check'
get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
