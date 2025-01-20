class Comment < ApplicationRecord
  belongs_to :note

  validates :content, presence: true
  validates :note_id, presence: true
end