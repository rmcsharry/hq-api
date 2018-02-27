class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.date :valid_from
      t.date :valid_to
      t.belongs_to :uploader, index: true, foreign_key: { to_table: :users }, type: :uuid, null: false
      t.belongs_to :owner, index: true, polymorphic: true, type: :uuid, null: false
    end
  end
end
