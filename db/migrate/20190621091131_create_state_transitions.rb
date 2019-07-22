class CreateStateTransitions < ActiveRecord::Migration[5.2]
  def change
    create_table :state_transitions, id: :uuid do |t|
      t.boolean  :is_successor
      t.string   :event
      t.string   :state, null: false
      t.string   :subject_type, null: false
      t.uuid     :subject_id, null: false
      t.uuid     :user_id

      t.datetime :created_at
    end

    add_reference :mandates, :previous_state_transition, index: true, type: :uuid
    add_foreign_key :mandates, :state_transitions, column: :previous_state_transition_id
    add_reference :mandates, :current_state_transition, index: true, type: :uuid
    add_foreign_key :mandates, :state_transitions, column: :current_state_transition_id

    add_index :state_transitions, %i(subject_type subject_id)
    add_index :state_transitions, %i(subject_type subject_id created_at), name: 'index_state_transitions_on_subject_and_created_at'
  end
end
