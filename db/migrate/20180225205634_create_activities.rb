class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.string :type
      t.timestamp :started_at
      t.timestamp :ended_at
      t.string :title
      t.text :description
      t.belongs_to :creator, index: true, foreign_key: { to_table: :users }, type: :uuid
    end

    create_table :activities_mandates, id: false do |t|
      t.belongs_to :activity, index: true, foreign_key: true, type: :uuid
      t.belongs_to :mandate, index: true, foreign_key: true, type: :uuid
    end

    create_table :activities_contacts, id: false do |t|
      t.belongs_to :activity, index: true, foreign_key: true, type: :uuid
      t.belongs_to :contact, index: true, foreign_key: true, type: :uuid
    end
  end
end
