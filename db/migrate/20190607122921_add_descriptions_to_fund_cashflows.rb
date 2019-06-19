class AddDescriptionsToFundCashflows < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_cashflows, :description_bottom, :text
    add_column :fund_cashflows, :description_top, :text
  end
end
