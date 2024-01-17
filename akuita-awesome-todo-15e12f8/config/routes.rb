require 'sidekiq/web'

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

    # The new code does not have this route, but it's in the existing code, so we keep it.
    post 'notes/:todo_id/associate_category/:category_id', to: 'notes#associate_with_category'

    # The existing code does not have this nested route, but it's in the new code, so we add it.
    resources :todos do
      resources :notes, only: %i[index create show update destroy] do
      end
      resources :attachments, only: [:create]
    end

    # The existing code has this route for notes outside of the todos resource, so we keep it.
    resources :notes, only: %i[index create show update destroy] do
    end
  end

  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
