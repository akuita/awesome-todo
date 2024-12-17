class CreateAuditLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_logs do |t|
      t.string :action, null: false
      t.string :affected_resource, null: false
      t.datetime :timestamp, null: false
      t.string :user_ip, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end