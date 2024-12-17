class AuditLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true
  validates :affected_resource, presence: true
  validates :timestamp, presence: true
  validates :user_ip, presence: true
end