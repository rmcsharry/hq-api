class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists, id: :uuid do |t|
      t.references :user, foreign_key: true, null: false, type: :uuid
      t.string :aasm_state, default: :active, null: false
      t.text :comment
      t.string :name

      t.timestamps
    end
  end
end
