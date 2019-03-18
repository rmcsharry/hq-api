class AddAlternativeInvestmentsToBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :alternative_investments, :boolean, default: false, null: false
  end
end
