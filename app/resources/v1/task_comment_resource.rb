# frozen_string_literal: true

module V1
  # Defines the TaskComment resource for the API
  class TaskCommentResource < BaseResource
    attributes(
      :comment,
      :created_at,
      :updated_at
    )

    has_one :contact
    has_one :task
    has_one :user

    filters(
      :task_id
    )

    class << self
      def updatable_fields(context)
        super(context) - %i[
          created_at
          updated_at
        ]
      end
    end
  end
end
