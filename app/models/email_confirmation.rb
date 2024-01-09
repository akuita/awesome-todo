class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :token, presence: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :expires_at, presence: true
  validates :user_id, presence: true

  # methods
  def confirm!
    update(confirmed: true)
  end

  def expired?
    expires_at < Time.current
  end
end
