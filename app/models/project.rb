# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :user
  has_many :figma_imports
  has_many :use_cases
  has_many :errors

  validates :name, presence: true
end
