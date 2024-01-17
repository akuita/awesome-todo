class Todo < ApplicationRecord
  enum priority: { low: 0, medium: 1, high: 2 }
  enum recurring: { daily: 0, weekly: 1, monthly: 2 }, _suffix: true

  belongs_to :user
  belongs_to :category, optional: true
  has_many :attachments, dependent: :destroy

  validates :title, presence: true, uniqueness: { scope: :user_id }
  validate :due_date_in_future
  validates :priority, inclusion: { in: priorities.keys }
  validates :recurring, inclusion: { in: recurrings.keys }, allow_nil: true

  private

  def due_date_in_future
    if due_date.present? && due_date < Time.now
      errors.add(:due_date, I18n.t('activerecord.errors.messages.in_the_future'))
    end
  end
end
