
# typed: true
class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
  end

  def log_email_confirmation(user_details, status)
    logger.info "Email confirmation for user #{user_details[:email]}: #{status}"
  end
end
