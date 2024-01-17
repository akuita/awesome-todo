class Note < ApplicationRecord
  # validations

  validates :title, presence: true
  validates :title, length: { in: 0..255 }, if: :title?
  validates :title, uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.messages.taken') }
  validates :description, presence: true
  validates :user_id, presence: true
  validates :due_date, presence: true
  validates :description, length: { in: 0..65_535 }, if: :description?

  # Custom validation methods
  validate :due_date_cannot_be_in_the_past

  # end for validations

  class << self
  end

  private

  def due_date_cannot_be_in_the_past
    errors.add(:due_date, I18n.t('activerecord.errors.messages.datetime_in_future')) if due_date.present? && due_date < Time.now
  end
end
