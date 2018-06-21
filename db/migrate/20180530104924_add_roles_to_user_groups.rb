class AddRolesToUserGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :user_groups, :roles, :string, array: true, default: []
  end
end
