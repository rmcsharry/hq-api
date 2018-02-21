class AddMandate < ActiveRecord::Migration[5.1]
  def change
    create_table :mandates, id: :uuid do |t|
      t.string :state
      t.string :category
      t.text :comment
      t.string :valid_from
      t.string :valid_to
      t.string :datev_creditor_id
      t.string :datev_debitor_id
      t.string :psplus_id

      t.timestamps
    end

    add_reference :mandates, :primary_consultant, index: true, type: :uuid
    add_foreign_key :mandates, :contacts, column: :primary_consultant_id

    add_reference :mandates, :secondary_consultant, index: true, type: :uuid
    add_foreign_key :mandates, :contacts, column: :secondary_consultant_id

    add_reference :mandates, :assistant, index: true, type: :uuid
    add_foreign_key :mandates, :contacts, column: :assistant_id

    add_reference :mandates, :bookkeeper, index: true, type: :uuid
    add_foreign_key :mandates, :contacts, column: :bookkeeper_id
  end
end
