# frozen_string_literal: true

module V1
  class StateTransitionSubjectResource < JSONAPI::Resource; end

  # Defines the StateTransition resource for the API
  class StateTransitionResource < BaseResource
    attributes(
      :created_at,
      :event,
      :is_successor,
      :state
    )

    has_one :subject, polymorphic: true, class_name: 'StateTransitionSubject'
    has_one :user, class_name: 'User'

    filters(:subject_id)

    sort :created_at, apply: lambda { |records, direction, _context|
      records.order("created_at #{direction}")
    }
  end
end
