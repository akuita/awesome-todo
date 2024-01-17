class Todo < ApplicationRecord
  enum priority: { low: 0, medium: 1, high: 2 }
  enum recurring: { daily: 0, weekly: 1, monthly: 2 }, _suffix: true

  belongs_to :user
  belongs_to :category, optional: true
  has_many :attachments, dependent: :destroy

  # Merged validations
  validates :title, presence: { message: I18n.t('activerecord.errors.messages.blank') }, uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.messages.taken') }
  validate :due_date_in_future, :due_date_conflict, :custom_validation

  # Use the new code's priority validation message and keep the condition from the new code
  validates :priority, inclusion: { in: priorities.keys, message: I18n.t('activerecord.errors.messages.invalid_priority') }, if: -> { priority.present? }
  # Keep the allow_nil option from the existing code and add the new code's recurring validation message
  validates :recurring, inclusion: { in: recurrings.keys, message: I18n.t('activerecord.errors.messages.invalid_recurring') }, allow_nil: true
  validates :user_id, presence: true
  validate :user_exists

  def self.due_date_conflict?(due_date, user_id)
    where(user_id: user_id).where.not(due_date: nil).exists?(['due_date = ?', due_date])
  end

  private

  # Use Time.current for timezone awareness instead of Time.now from the existing code
  def due_date_in_future
    if due_date.present? && due_date < Time.current
      errors.add(:due_date, I18n.t('activerecord.errors.messages.datetime_in_future'))
    end
  end
  
  def due_date_conflict
    # Use the error message from the new code for due_date_conflict
    if due_date.present? && self.class.due_date_conflict?(due_date, user_id)
      errors.add(:due_date, 'This due date conflicts with another scheduled todo.')
    end
  end

  def user_exists
    errors.add(:user_id, "User not found.") unless User.exists?(self.user_id)
  end

  def custom_validation
    unless title.present?
      errors.add(:title, I18n.t('activerecord.errors.messages.blank'))
    end

    # Add more custom validations as needed
  end
end
