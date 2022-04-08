class AddOmniauthToAdmins < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :provider, :string
    add_column :admins, :uid, :string
    add_column :admins, :access_token, :string
    add_column :admins, :expires_at, :integer
    add_column :admins, :refresh_token, :string
    add_column :admins, :scope, :string
  end
end
