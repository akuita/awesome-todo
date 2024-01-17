
class Note < ApplicationRecord
  # validations

  validates :title, length: { in: 0..255 }, if: :title?
  validates :description, length: { in: 0..65_535 }, if: :description?
  validates :title, uniqueness: { scope: :user_id, message: "Title already exists" }

  # Custom validation methods
  validate :due_date_cannot_be_in_the_past

  # end for validations

  class << self
  end

  private

  def due_date_cannot_be_in_the_past
    errors.add(:due_date, "can't be in the past") if due_date.present? && due_date < Time.now
  end
end
