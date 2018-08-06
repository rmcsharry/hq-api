class AddImportIds < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :import_id, :integer
    add_column :mandates, :import_id, :integer
  end
end
