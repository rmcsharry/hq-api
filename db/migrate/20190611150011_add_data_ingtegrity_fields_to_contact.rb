class AddDataIngtegrityFieldsToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :data_integrity_score, :decimal, precision: 4, scale: 3, default: 0
    add_column :contacts, :data_integrity_missing_fields, :string, array: true, default: []

    add_index :contacts, :data_integrity_score
  end
end
