class CreateInterPersonRelationships < ActiveRecord::Migration[5.2]
  def change
    create_table :inter_person_relationships, id: :uuid do |t|
      t.string :role, null: false
      t.belongs_to :target_person, index: true, foreign_key: { to_table: :contacts }, type: :uuid, null: false
      t.belongs_to :source_person, index: true, foreign_key: { to_table: :contacts }, type: :uuid, null: false

      t.timestamps
    end
  end
end
