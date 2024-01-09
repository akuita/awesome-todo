
class UserPasswordManagementTool < ApplicationRecord
  def self.create_association(user_id, tool_id)
    create(user_id: user_id, password_management_tool_id: tool_id)
  end

  # existing code...
end
