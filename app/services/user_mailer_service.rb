# typed: true
class UserMailerService < BaseService
  def send_confirmation_instructions(user, token)
    begin
      Devise.mailer.confirmation_instructions(user, token).deliver_now
    rescue => e
      logger.error "Failed to send confirmation instructions to #{user.email}: #{e.message}"
      raise e
    end
  end
end
