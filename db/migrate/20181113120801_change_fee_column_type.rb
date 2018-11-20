class ChangeFeeColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :mandates, :prospect_assets_under_management, :decimal, precision: 20, scale: 10
    change_column :mandates, :prospect_fees_percentage, :decimal, precision: 20, scale: 10
    change_column :mandates, :prospect_fees_fixed_amount, :decimal, precision: 20, scale: 10
    change_column :mandates, :prospect_fees_min_amount, :decimal, precision: 20, scale: 10
  end
end
