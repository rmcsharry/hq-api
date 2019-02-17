class AddStateToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :aasm_state, :string, null: false, default: 'created'
  end
end
