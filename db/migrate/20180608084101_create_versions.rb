# This migration creates the `versions` table, the only schema PT requires.
# All other migrations PT provides are optional.
class CreateVersions < ActiveRecord::Migration[5.2]

  def change
    create_table :versions, id: :uuid do |t|
      t.string   :item_type, null: false
      t.uuid     :item_id,   null: false
      t.string   :event,     null: false
      t.uuid     :whodunnit
      t.jsonb    :object
      t.jsonb    :object_changes
      t.string   :parent_item_type
      t.uuid     :parent_item_id

      t.datetime :created_at
    end
    add_index :versions, %i(item_type item_id)
  end
end
