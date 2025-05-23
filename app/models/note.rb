class Note < ApplicationRecord
  # validations

  validates :title, length: { in: 0..255 }, if: :title?
  validates :tags, length: { in: 0..255 }, if: :title?
  validates :description, length: { in: 0..65_535 }, if: :description?

  # end for validations

  class << self
  end
end
