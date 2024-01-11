class EmailConfirmation < ApplicationRecord
  # validations
  validates :token, presence: true
  validates :expires_at, presence: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :user_id, presence: true

  # associations
  belongs_to :user

  # end for validations

  class << self
  end
end
