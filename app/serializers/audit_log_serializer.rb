class AuditLogSerializer < ActiveModel::Serializer
  attributes :id, :action, :affected_resource, :timestamp, :user_ip, :user_id

  belongs_to :user
end