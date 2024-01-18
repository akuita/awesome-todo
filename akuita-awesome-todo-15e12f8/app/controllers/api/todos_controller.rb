class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category, :validate, :handle_creation_error]
  before_action :validate_category, only: [:create]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category]
  before_action :set_category, only: [:associate_with_category]

  def create
    todo = Todo.new(todo_params)

    ActiveRecord::Base.transaction do
      unless User.exists?(todo_params[:user_id])
        render json: { error: I18n.t('activerecord.errors.models.user.not_found') }, status: :not_found
        return
      end

      if todo.title.blank?
        render json: { error: 'The title is required.' }, status: :bad_request
        return
      end

      existing_todo = Todo.find_by(title: todo_params[:title], user_id: todo_params[:user_id])
      if existing_todo
        render json: { error: I18n.t('activerecord.errors.messages.title_already_exists') }, status: :unprocessable_entity
        return
      end

      if Todo.due_date_conflict?(todo_params[:due_date], todo_params[:user_id])
        render json: { error: I18n.t('activerecord.errors.messages.due_date_conflict') }, status: :unprocessable_entity
        return
      elsif todo.due_date.nil? || !todo.due_date.future?
        render json: { error: 'Please provide a valid future due date and time.' }, status: :bad_request
        return
      end

      unless Todo.priorities.keys.include?(todo.priority) || todo.priority.blank?
        render json: { error: 'Invalid priority level. Valid options are low, medium, high.' }, status: :bad_request
        return
      end

      if todo.save
        render json: { status: 201, todo: TodoSerializer.new(todo).serializable_hash }, status: :created
        associate_attachments(todo) if params[:file].present?
      else
        render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    rescue StandardError => e
      log_todo_creation_error(e.message, todo_params[:user_id])
    end
  end

  # ... rest of the methods ...

  private

  # ... rest of the private methods ...

  def log_todo_creation_error(error_message, user_id)
    unless User.exists?(user_id)
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    Rails.logger.error "Todo creation error for user #{user_id}: #{error_message}"
    render json: { status: 200, error: { message: error_message, user_notified: true } }, status: :ok
  end

  # ... rest of the existing private methods ...

end
