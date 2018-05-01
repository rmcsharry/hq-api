class AddContactIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :comment, :text

    add_reference :users, :contact, index: true, type: :uuid
    add_foreign_key :users, :contacts, column: :contact_id
  end
end
