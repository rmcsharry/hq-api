class AddTypeToFunds < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :type, :string
    Fund.reset_column_information
    Fund.where(asset_class: 'private_debt').update_all(type: 'Fund::PrivateDebt')
    Fund.where(asset_class: 'private_equity').update_all(type: 'Fund::PrivateEquity')
    Fund.where(asset_class: 'real_estate').update_all(type: 'Fund::RealEstate')
    remove_column :funds, :asset_class, :string
  end
end
