class DropPsplusIdFromInvestorsAndAddPsplusPeIdToMandates < ActiveRecord::Migration[5.2]
  def change
    remove_column :investors, :psplus_id
    add_column :mandates, :psplus_pe_id, :string
  end
end
