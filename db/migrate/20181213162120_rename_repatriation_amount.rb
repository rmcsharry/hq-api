class RenameRepatriationAmount < ActiveRecord::Migration[5.2]
  def change
    rename_column :investor_cashflows, :distribution_reduction_amount, :distribution_repatriation_amount
    remove_column :investors, :decimal
  end
end
