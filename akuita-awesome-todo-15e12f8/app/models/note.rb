class Note < ApplicationRecord
  # validations
  enum priority: { low: 0, medium: 1, high: 2 }
  enum recurring: { daily: 0, weekly: 1, monthly: 2 }, _suffix: true, _default: nil

  belongs_to :user
  belongs_to :category, optional: true

  validates :title, presence: true
  validates :title, uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.messages.taken') }
  validates :title, length: { in: 0..255 }, if: :title?
  validates :description, presence: true
  validates :user_id, presence: true
  validates :due_date, presence: true
  validates :due_date, comparison: { greater_than: Time.now }, on: :create
  validates :description, length: { in: 0..65_535 }, if: :description?
  validates :category_id, presence: true, if: -> { category_id.present? }

  # Custom validation methods
  validate :due_date_cannot_be_in_the_past
  validate :category_must_exist, if: -> { category_id.present? }

  # end for validations

  # associations

  class << self
  end

  private
  
  def due_date_cannot_be_in_the_past
    errors.add(:due_date, I18n.t('activerecord.errors.messages.datetime_in_future')) if due_date.present? && due_date < Time.now
  end

  def category_must_exist
    errors.add(:category_id, I18n.t('activerecord.errors.messages.invalid')) unless Category.exists?(self.category_id)
  end
end
