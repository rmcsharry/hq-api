class AddContactPersonsToInvestor < ActiveRecord::Migration[5.2]
  def change
    add_reference :investors, :primary_contact, index: true, type: :uuid
    add_foreign_key :investors, :contacts, column: :primary_contact_id

    add_reference :investors, :secondary_contact, index: true, type: :uuid
    add_foreign_key :investors, :contacts, column: :secondary_contact_id
  end
end
