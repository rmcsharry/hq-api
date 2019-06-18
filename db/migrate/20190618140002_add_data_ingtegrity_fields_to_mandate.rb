class AddDataIngtegrityFieldsToMandate < ActiveRecord::Migration[5.2]
  def change
    add_column :mandates, :data_integrity_score, :decimal, precision: 5, scale: 4, default: 0
    add_column :mandates, :data_integrity_missing_fields, :string, array: true, default: []

    add_index :mandates, :data_integrity_score
  end
end
