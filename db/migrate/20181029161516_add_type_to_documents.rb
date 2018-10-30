class AddTypeToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :type, :string
    Document.reset_column_information
    Document.update_all(type: 'Document')
  end
end
