class AddAdditionalKpIsToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_reports, :tvpi, :decimal, precision: 20, scale: 10
    add_column :fund_reports, :dpi, :decimal, precision: 20, scale: 10
    add_column :fund_reports, :rvpi, :decimal, precision: 20, scale: 10
  end
end
