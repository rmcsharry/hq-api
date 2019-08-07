class AddAddressColumnsFromInvestorToMandate < ActiveRecord::Migration[5.2]
  def up
    add_belongs_to :mandates, :contact_address, foreign_key: { to_table: :addresses }, type: :uuid, index: true
    add_belongs_to :mandates, :legal_address, foreign_key: { to_table: :addresses }, type: :uuid, index: true
    add_belongs_to :mandates, :primary_contact, foreign_key: { to_table: :contacts }, type: :uuid, index: true
    add_belongs_to :mandates, :primary_owner, foreign_key: { to_table: :contacts }, type: :uuid, index: true
    add_belongs_to :mandates, :secondary_contact, foreign_key: { to_table: :contacts }, type: :uuid, index: true
    add_column :mandates, :contact_salutation_primary_contact, :boolean
    add_column :mandates, :contact_salutation_primary_owner, :boolean
    add_column :mandates, :contact_salutation_secondary_contact, :boolean

    Mandate.reset_column_information

    Mandate.all.each do |mandate|
      investor = mandate.investments.order(created_at: :desc).first
      next if investor.nil?

      mandate.contact_address_id = investor.contact_address_id
      mandate.legal_address_id = investor.legal_address_id
      mandate.primary_contact_id = investor.primary_contact_id
      mandate.primary_owner_id = investor.primary_owner_id
      mandate.secondary_contact_id = investor.secondary_contact_id
      mandate.contact_salutation_primary_contact = investor.contact_salutation_primary_contact
      mandate.contact_salutation_primary_owner = investor.contact_salutation_primary_owner
      mandate.contact_salutation_secondary_contact = investor.contact_salutation_secondary_contact
      mandate.save!
    end

    remove_column :investors, :contact_address_id
    remove_column :investors, :contact_salutation_primary_contact
    remove_column :investors, :contact_salutation_primary_owner
    remove_column :investors, :contact_salutation_secondary_contact
    remove_column :investors, :legal_address_id
    remove_column :investors, :primary_contact_id
    remove_column :investors, :primary_owner_id
    remove_column :investors, :secondary_contact_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
