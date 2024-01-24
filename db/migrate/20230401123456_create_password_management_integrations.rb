class CreatePasswordManagementIntegrations < ActiveRecord::Migration[7.0]
  def change
    create_table :password_management_integrations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :tool_name
      t.text :integration_data

      t.timestamps
    end
  end
end
