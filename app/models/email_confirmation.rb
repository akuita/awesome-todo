class EmailConfirmation < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :expires_at, presence: true
  validates :user_id, presence: true

  # Methods
  def confirm!
    update(confirmed: true, expires_at: Time.now.utc)
  end

  def expired?
    expires_at < Time.now.utc
  end
end
