class AddCompanyToFund < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :company, :string
  end
end
