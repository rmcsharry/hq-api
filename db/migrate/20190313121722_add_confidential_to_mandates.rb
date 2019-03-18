class AddConfidentialToMandates < ActiveRecord::Migration[5.2]
  def change
    add_column :mandates, :confidential, :boolean, default: false, null: false
  end
end
