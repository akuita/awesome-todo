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

    # The route for creating a todo item is already present in the new code
    post '/todos', to: 'todos#create'

    # Keep the route from the existing code
    post 'notes/:todo_id/associate_category/:category_id', to: 'notes#associate_with_category'

    # Add the nested resources from the new code
    resources :todos do
      resources :notes, only: %i[index create show update destroy] do
      end
      # The validate route is not needed according to the requirement
      # Removed the following line:
      # post 'validate', to: 'todos#validate'
      resources :attachments, only: [:create]
    end

    # The route for creating notes is duplicated in the new code, keep only one
    # Removed the following line:
    # post '/api/notes', to: 'api/notes#create', as: 'create_note'
    # Keep the route for notes from the existing code
    resources :notes, only: %i[index create show update destroy] do
    end

    # The new route for attaching files to a todo item
    post '/todos/:todo_id/attachments', to: 'attachments#create'
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
