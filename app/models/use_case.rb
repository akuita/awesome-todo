# frozen_string_literal: true

class UseCase < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :description, presence: true
  validates :project_id, presence: true

  # Add any custom logic here
end
