class PasswordManagementTool < ApplicationRecord
  # validations

  validates :name, length: { in: 0..255 }, if: :name?
  validates :integration_details, length: { in: 0..65_535 }, if: :integration_details?

  # end for validations

  class << self
    def exists_with_id?(tool_id)
      exists?(tool_id)
    end
  end
end
