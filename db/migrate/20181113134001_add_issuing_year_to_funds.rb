class AddIssuingYearToFunds < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :issuing_year, :integer
  end
end
