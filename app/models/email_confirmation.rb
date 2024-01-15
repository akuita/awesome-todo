class EmailConfirmation < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :token, presence: true
  validates :expires_at, presence: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :user_id, presence: true

  # methods
  def expired?
    Time.current > expires_at
  end

  def confirm!
    update(confirmed: true) unless confirmed?
  end

  def confirmed?
    confirmed
  end
end
