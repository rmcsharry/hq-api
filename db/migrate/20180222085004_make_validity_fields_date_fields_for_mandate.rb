class MakeValidityFieldsDateFieldsForMandate < ActiveRecord::Migration[5.1]
  def change
    change_column :mandates, :valid_from, 'date USING valid_from::date'
    change_column :mandates, :valid_to, 'date USING valid_to::date'
    rename_column :mandates, :state, :aasm_state
  end
end
