class EmailConfirmation < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true
  validates :user_id, presence: true

  # Callbacks
  before_create :set_defaults

  private

  def set_defaults
    self.confirmed ||= false
  end
end
