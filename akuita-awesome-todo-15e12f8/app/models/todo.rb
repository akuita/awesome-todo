class Todo < ApplicationRecord
  enum priority: { low: 0, medium: 1, high: 2 }
  enum recurring: { daily: 0, weekly: 1, monthly: 2 }, _suffix: true

  belongs_to :user
  belongs_to :category, optional: true
  has_many :attachments, dependent: :destroy

  validates :title, presence: { message: "The title is required." }, uniqueness: { scope: :user_id }
  validate :due_date_in_future, :due_date_conflict

  validates :priority, inclusion: { in: priorities.keys, message: "Invalid priority level. Valid options are low, medium, high." }
  validates :recurring, inclusion: { in: recurrings.keys }, allow_nil: true
  validates :user_id, presence: true
  validate :user_exists

  def self.due_date_conflict?(due_date, user_id)
    where(user_id: user_id).where.not(due_date: nil).exists?(['due_date = ?', due_date])
  end

  private

  def due_date_in_future
    if due_date.present? && due_date < Time.now
      errors.add(:due_date, "Please provide a valid future due date and time.")
    end
  end
  
  def due_date_conflict
    if due_date.present? && self.class.due_date_conflict?(due_date, user_id)
      errors.add(:due_date, 'This due date conflicts with another scheduled todo.')
    end
  end

  def user_exists
    errors.add(:user_id, "User not found.") unless User.exists?(self.user_id)
  end
end
