class CreateFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :funds, id: :uuid do |t|
      t.integer :duration
      t.integer :duration_extension
      t.string :aasm_state, null: false
      t.string :asset_class
      t.string :commercial_register_number
      t.string :commercial_register_office
      t.string :currency
      t.string :name, null: false
      t.string :psplus_asset_id
      t.string :region
      t.string :strategy
      t.text :comment

      t.belongs_to :capital_management_company, index: true, foreign_key: { to_table: :contacts }, type: :uuid
      t.belongs_to :legal_address, index: true, foreign_key: { to_table: :addresses }, type: :uuid
      t.belongs_to :primary_contact_address, index: true, foreign_key: { to_table: :addresses }, type: :uuid

      t.timestamps
    end
  end
end
