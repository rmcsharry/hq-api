# frozen_string_literal: true

# Defines the access permissions for the StateTransition resource
class StateTransitionPolicy < ApplicationPolicy
  # The StateTransition resource allows access only to the index endpoint
  def index?
    role? :contacts_read
  end
end
