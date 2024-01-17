class Api::TodosController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_locale
  before_action :doorkeeper_authorize!, only: [:create, :associate_with_category, :handle_creation_error]
  before_action :validate_category, only: [:create]
  before_action :set_todo, only: [:show, :update, :destroy, :complete, :uncomplete, :associate_with_category]
  before_action :set_category, only: [:associate_with_category]

  # ... existing actions ...

  # New action to handle todo creation errors
  def handle_creation_error
    error_details = params[:error]

    if error_details.blank?
      render json: { error: 'Error details are required.' }, status: :bad_request
      return
    end

    TodoErrorLoggingJob.perform_later(error_details, params.except(:error, :controller, :action))

    render json: { message: 'The error has been logged and will be reviewed by our technical team.' }, status: :ok
  end

  # ... rest of the existing private methods ...

  private

  # ... existing private methods ...

end
