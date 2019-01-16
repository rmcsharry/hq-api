class RemoveNotNullContraintFromDocumentsOwner < ActiveRecord::Migration[5.2]
  def change
    change_column :documents, :owner_id, :uuid, null: true
    change_column :documents, :owner_type, :string, null: true
  end
end
