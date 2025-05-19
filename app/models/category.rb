class Category < ApplicationRecord
  validates :name, length: { in: 0..255 }, if: :name?
end
