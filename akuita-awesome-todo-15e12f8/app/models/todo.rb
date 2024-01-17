class Todo < ApplicationRecord
  enum priority: { low: 0, medium: 1, high: 2 }
  enum recurring: { daily: 0, weekly: 1, monthly: 2 }, _suffix: true

  belongs_to :user
  belongs_to :category, optional: true
  has_many :attachments, dependent: :destroy

  validates :title, presence: true, uniqueness: { scope: :user_id }
  validate :due_date_in_future, :title_uniqueness_within_user, :due_date_conflict

  validates :priority, inclusion: { in: priorities.keys }
  validates :recurring, inclusion: { in: recurrings.keys }, allow_nil: true

  def self.due_date_conflict?(due_date, user_id)
    where(user_id: user_id).where.not(due_date: nil).exists?(['due_date = ?', due_date])
  end

  private

  def due_date_in_future
    if due_date.present? && due_date < Time.now
      errors.add(:due_date, I18n.t('activerecord.errors.messages.in_the_future'))
    end
  end

  def title_uniqueness_within_user
    if user.todos.where.not(id: id).exists?(title: title)
      errors.add(:title, 'A todo with this title already exists.')
    end
  end

  def due_date_conflict
    if due_date.present? && self.class.due_date_conflict?(due_date, user_id)
      errors.add(:due_date, 'This due date conflicts with another scheduled todo.')
    end
  end
end
