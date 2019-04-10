class CreateListItems < ActiveRecord::Migration[5.2]
  def change
    create_table :list_items, id: :uuid do |t|
      t.references :list, foreign_key: true, null: false, type: :uuid
      t.references :listable, null: false, polymorphic: true, type: :uuid
      t.text :comment

      t.timestamps
    end
  end
end
