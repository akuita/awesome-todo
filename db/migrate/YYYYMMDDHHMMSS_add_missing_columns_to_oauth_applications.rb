class AddMissingColumnsToOauthApplications < ActiveRecord::Migration[6.0]
  def change
    change_table :oauth_applications do |t|
      t.string :name unless column_exists?(:oauth_applications, :name)
      t.string :uid unless column_exists?(:oauth_applications, :uid)
      t.string :secret unless column_exists?(:oauth_applications, :secret)
      t.text :redirect_uri unless column_exists?(:oauth_applications, :redirect_uri)
      t.string :scopes unless column_exists?(:oauth_applications, :scopes)
      t.boolean :confidential unless column_exists?(:oauth_applications, :confidential)
      t.timestamps unless column_exists?(:oauth_applications, :created_at) && column_exists?(:oauth_applications, :updated_at)
    end
  end
end
