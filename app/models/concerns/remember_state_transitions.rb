# frozen_string_literal: true

# Concern to keep track of changes of the `aasm_state` attribute of models
module RememberStateTransitions
  extend ActiveSupport::Concern

  included do
    has_many :state_transitions,
             -> { order(created_at: :asc) },
             as: :subject,
             inverse_of: :subject,
             dependent: :destroy

    after_create :remember_state_transition
    after_update :remember_state_transition, if: :should_remember_state_transition?

    # respond to (current|previous)_state_transition getter and setter even if
    # the including entity does not have the respective `belongs_to` relations
    # declared
    def method_missing(method_name, *arguments, &block)
      return if method_name.to_s =~ /^(current|previous)_state_transition(.*)$/

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s =~ /^(current|previous)_state_transition(.*)$/ ||
        super
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def remember_state_transition(updater = nil)
    next_state = aasm.current_event.nil? ? aasm_state : aasm.to_state
    self.previous_state_transition = current_state_transition
    self.current_state_transition = StateTransition.create!(
      event: aasm.current_event,
      is_successor: successor_state?(next_state),
      state: next_state,
      subject_id: id,
      subject_type: self.class.name,
      user: updater
    )
  rescue ActiveRecord::RecordInvalid
    abort_current_transaction
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def permitted_successor_states
    permitted_state_names(successors: true)
  end

  def permitted_predecessor_states
    permitted_state_names(successors: false)
  end

  private

  # Only remember state transition through traditional `after_update` callback
  # if it will not be remembered by an aasm's `after_all_transitions` callback
  def should_remember_state_transition?
    saved_change_to_aasm_state? && aasm.current_event.nil?
  end

  # Array of permitted state names before or after given state
  # @param successors [boolean] look for permitted successor- (or else predecessor-) states
  # @return [Array<symbol>]
  def permitted_state_names(successors:)
    offset = successors ? 1 : 0
    aasm.states.map(&:name).split(state.to_sym)[offset] &
      aasm.states(permitted: true).map(&:name)
  end

  # Whether or not a state is a successor state
  # @param state [symbol] state name in question
  # @return [boolean]
  def successor_state?(state)
    !permitted_predecessor_states.include?(state)
  end

  def abort_current_transaction
    throw :abort
  end
end
