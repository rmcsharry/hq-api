class AddAumAndFeesToMandates < ActiveRecord::Migration[5.2]
  def change
    add_column :mandates, :default_currency, :string
    add_column :mandates, :prospect_assets_under_management, :float
    add_column :mandates, :prospect_fees_percentage, :float
    add_column :mandates, :prospect_fees_fixed_amount, :float
    add_column :mandates, :prospect_fees_min_amount, :float
  end
end
