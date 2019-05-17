class AddLegalEntityFieldsToFunds < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :tax_office, :string
    add_column :funds, :tax_id, :string
    add_column :funds, :global_intermediary_identification_number, :string
    add_column :funds, :us_employer_identification_number, :string
    add_column :funds, :de_central_bank_id, :string
    add_column :funds, :de_foreign_trade_regulations_id, :string
  end
end
