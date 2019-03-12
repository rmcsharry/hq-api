class AddCapitalAccountNumberAndPsplusIdToInvestors < ActiveRecord::Migration[5.2]
  def change
    add_column :investors, :capital_account_number, :string
    add_column :investors, :psplus_id, :string
  end
end
