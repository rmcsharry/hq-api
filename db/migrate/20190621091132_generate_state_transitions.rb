class GenerateStateTransitions < ActiveRecord::Migration[5.2]
  def up
    Mandate.find_in_batches do |batch|
      batch.each do |mandate|
        current_state_transition = nil
        mandate.versions.select { |v| v.object_changes["aasm_state"] }.each do |version|
          state = version.object_changes["aasm_state"].second
          state = 'prospect_not_qualified' if state == 'prospect'
          current_state_transition = StateTransition.create!(
            is_successor: successor_state?(state: state, old_state: current_state_transition&.state),
            event: "become_#{state}",
            state: state,
            subject: mandate,
            user: version.whodunnit ? User.find(version.whodunnit) : nil,
            created_at: version.created_at
          )
          mandate.update_columns(
            previous_state_transition_id: mandate.current_state_transition_id,
            current_state_transition_id: current_state_transition.id
          )
        end
      end
    end
  end

  def permitted_state_names(successors:, old_state:)
    offset = successors ? 1 : 0
    Mandate.aasm.states.map(&:name).split(old_state&.to_sym)[offset] &
      Mandate.aasm.states.map(&:name)
  end

  def successor_state?(state:, old_state:)
    !permitted_state_names(successors: false, old_state: old_state).include?(state.to_sym)
  end
end
