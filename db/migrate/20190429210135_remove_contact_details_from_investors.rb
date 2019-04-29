class RemoveContactDetailsFromInvestors < ActiveRecord::Migration[5.2]
  def change
    remove_column :investors, :contact_email_id, :uuid
    remove_column :investors, :contact_phone_id, :uuid
  end
end
