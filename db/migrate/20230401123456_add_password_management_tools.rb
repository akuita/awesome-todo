class AddPasswordManagementTools < ActiveRecord::Migration[6.0]
  def change
    create_table :password_management_tools do |t|
      t.string :name
      t.text :integration_details

      t.timestamps null: false
    end
  end
end
