class CreateMandateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :mandate_groups, id: :uuid do |t|
      t.string :name
      t.string :group_type
      t.text :comment

      t.timestamps
    end

    create_table :user_groups, id: :uuid do |t|
      t.string :name

      t.timestamps
    end

    create_table :mandate_groups_mandates, id: false do |t|
      t.belongs_to :mandate, index: true, foreign_key: true, type: :uuid
      t.belongs_to :mandate_group, index: true, foreign_key: true, type: :uuid
    end

    create_table :mandate_groups_user_groups, id: false do |t|
      t.belongs_to :user_group, index: true, foreign_key: true, type: :uuid
      t.belongs_to :mandate_group, index: true, foreign_key: true, type: :uuid
    end

    create_table :user_groups_users, id: false do |t|
      t.belongs_to :user, index: true, foreign_key: true, type: :uuid
      t.belongs_to :user_group, index: true, foreign_key: true, type: :uuid
    end
  end
end
