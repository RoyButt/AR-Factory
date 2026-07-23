class AddPermissionsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :view_only, :boolean, default: false, null: false
    add_column :users, :allowed_sections, :text
  end
end
