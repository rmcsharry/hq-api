class CreateContactDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_details, id: :uuid do |t|
      t.string :type
      t.string :category
      t.string :value
      t.boolean :primary, null: false, default: false
      t.belongs_to :contact, index: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
