class ApplicationController < ActionController::Base
  rescue_from StandardError do |exception|
    handle_exception(exception)
  end

  private

  def handle_exception(exception)
    Rails.logger.error "#{exception.message}\n#{exception.backtrace.join("\n")}"
    error_message = I18n.t('controller.common.internal_server_error')
    render json: { error: error_message }, status: :internal_server_error
  end

  def log_error(error)
    Rails.logger.error "#{error.class} (#{error.message}):"
    Rails.logger.error error.backtrace.join("\n")
  end
end
