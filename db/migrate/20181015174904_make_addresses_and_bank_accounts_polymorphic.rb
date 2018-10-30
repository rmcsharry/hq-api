class MakeAddressesAndBankAccountsPolymorphic < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :owner_type, :string
    rename_column :addresses, :contact_id, :owner_id
    Address.reset_column_information
    Address.update_all(owner_type: 'Contact')
    add_index :addresses, %i(owner_type owner_id)
    change_column :addresses, :owner_id, :uuid, null: false
    change_column :addresses, :owner_type, :string, null: false

    add_column :bank_accounts, :owner_type, :string
    rename_column :bank_accounts, :mandate_id, :owner_id
    rename_column :bank_accounts, :owner, :owner_name
    remove_foreign_key :bank_accounts, column: :owner_id
    BankAccount.reset_column_information
    BankAccount.update_all(owner_type: 'Mandate')
    remove_index :bank_accounts, :owner_id
    add_index :bank_accounts, %i(owner_type owner_id)
    change_column :bank_accounts, :owner_id, :uuid, null: false
    change_column :bank_accounts, :owner_type, :string, null: false
  end
end
