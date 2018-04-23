class CreateOrganizationMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_members, id: :uuid do |t|
      t.string :role, null: false
      t.belongs_to :organization, index: true, foreign_key: { to_table: :contacts }, type: :uuid, null: false
      t.belongs_to :contact, index: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
