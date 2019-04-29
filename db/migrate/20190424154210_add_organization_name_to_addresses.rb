class AddOrganizationNameToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :organization_name, :string
  end
end
