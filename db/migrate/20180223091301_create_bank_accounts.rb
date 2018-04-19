class CreateBankAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :bank_accounts, id: :uuid do |t|
      t.string :account_type
      t.string :owner
      t.string :bank_account_number
      t.string :bank_routing_number
      t.string :iban
      t.string :bic
      t.string :currency

      t.belongs_to :mandate, foreign_key: true, index: true, type: :uuid
      t.belongs_to :bank, foreign_key: { to_table: :contacts } , index: true, type: :uuid

      t.timestamps
    end
  end
end
