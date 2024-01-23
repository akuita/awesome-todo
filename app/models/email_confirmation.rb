class EmailConfirmation < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :confirmed, inclusion: { in: [true, false] }
  validates :expires_at, presence: true
  validate :expiration_date_cannot_be_in_the_past

  def expiration_date_cannot_be_in_the_past
    errors.add(:expires_at, "can't be in the past") if expires_at && expires_at < Time.now
  end

  def confirm!
    update(confirmed: true, expires_at: nil) unless confirmed?
  end

  def confirmed?
    confirmed
  end
end
