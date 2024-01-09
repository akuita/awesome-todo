class AddUserPasswordManagementTools < ActiveRecord::Migration[6.0]
  def change
    create_table :user_password_management_tools do |t|
      t.timestamps null: false
    end
  end
end
