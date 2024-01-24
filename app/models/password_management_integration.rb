class PasswordManagementIntegration < ApplicationRecord
  belongs_to :user

  # Validations
  validates :tool_name, presence: true
  validates :user_id, presence: true

  # Constants
  TOOL_NAME_MAX_LENGTH = 255

  validates :tool_name, length: { maximum: TOOL_NAME_MAX_LENGTH }
end

