class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks, id: :uuid do |t|
      t.belongs_to :creator, index: true, foreign_key: { to_table: :users }, type: :uuid
      t.belongs_to :finisher, index: true, foreign_key: { to_table: :users }, type: :uuid
      t.belongs_to :subject, index: true, polymorphic: true, type: :uuid
      t.belongs_to :linked_object, index: true, polymorphic: true, type: :uuid

      t.string :aasm_state, null: false
      t.string :description, null: true
      t.string :title, null: false
      t.string :type, null: false

      t.datetime :finished_at
      t.datetime :due_at

      t.timestamps
    end

    create_table :tasks_users, id: false do |t|
      t.belongs_to :task, index: true, foreign_key: true, type: :uuid
      t.belongs_to :user, index: true, foreign_key: true, type: :uuid
    end
  end
end
