class CreateMandateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :mandate_members, id: :uuid do |t|
      t.string :member_type
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_reference :mandate_members, :contact, index: true, type: :uuid
    add_foreign_key :mandate_members, :contacts

    add_reference :mandate_members, :mandate, index: true, type: :uuid
    add_foreign_key :mandate_members, :mandates
  end
end
