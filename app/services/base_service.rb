# typed: true
class BaseService
  def initialize(*_args); end

  public def logger
    @logger ||= Rails.logger
  end

  def log_user_registration_event(user_info, event_type)
    log_level = event_type == 'User Registration Attempt' ? :info : :warn
    logger.public_send(log_level, "Event: #{event_type}, User Info: #{user_info}")
  end
end
