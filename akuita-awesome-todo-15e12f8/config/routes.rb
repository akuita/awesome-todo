
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

    # The new route for handling todo creation errors is added here
    post '/todos/error', to: 'todos#handle_todo_creation_error'

    # Keep the route from the existing code
    post 'notes/:todo_id/associate_category/:category_id', to: 'notes#associate_with_category'

    # Add the nested resources from the new code
    resources :todos do
      resources :notes, only: %i[index create show update destroy] do
      end
      resources :attachments, only: [:create]
    end

    # Keep the route for notes from the new code
    post '/api/notes', to: 'api/notes#create', as: 'create_note'
    # Keep the route for notes from the existing code
    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
