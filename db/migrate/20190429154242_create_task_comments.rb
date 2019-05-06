class CreateTaskComments < ActiveRecord::Migration[5.2]
  def change
    create_table :task_comments, id: :uuid do |t|
      t.text :comment

      t.belongs_to :task, index: true, foreign_key: true, type: :uuid, null: false
      t.belongs_to :user, index: true, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
