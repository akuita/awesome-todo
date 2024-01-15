
# typed: true
class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
  end

  def create_user_account(user_params)
    User.create_with_encrypted_password(user_params[:email], user_params[:password_hash])
  end
end
