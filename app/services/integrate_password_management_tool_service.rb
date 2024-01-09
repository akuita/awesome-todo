
class IntegratePasswordManagementToolService < BaseService
  def initialize(user_id, tool_id)
    @user_id = user_id
    @tool_id = tool_id
  end

  def call
    user = User.find_by(id: @user_id)
    tool = PasswordManagementTool.exists_with_id?(@tool_id)

    if user && tool
      UserPasswordManagementTool.create_association(@user_id, @tool_id)
      { success: true, message: 'Password management tool successfully integrated.' }
    else
      { success: false, message: 'Invalid user or tool ID.' }
    end
  rescue => e
    { success: false, message: e.message }
  end
end

class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
  end
end
