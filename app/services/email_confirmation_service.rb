# typed: true
class EmailConfirmationService < BaseService
  def initialize(token)
    @token = token
  end

  def confirm_email
    user = User.find_by_confirmation_token(@token)
    if user.nil?
      raise StandardError.new('Invalid or expired confirmation token.')
    end

    user.confirm_email
    user.save!

    # Assuming the method to generate an authentication token exists
    auth_token = user.generate_authentication_token

    { user: user, auth_token: auth_token }
  rescue StandardError => e
    logger.error "Email confirmation failed: #{e.message}"
    raise
  end
end

