class AddContactSalutationFlagsToInvestors < ActiveRecord::Migration[5.2]
  def change
    add_column :investors, :contact_salutation_primary_owner, :boolean
    add_column :investors, :contact_salutation_primary_contact, :boolean
    add_column :investors, :contact_salutation_secondary_contact, :boolean
  end
end
