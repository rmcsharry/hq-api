# frozen_string_literal: true

module V1
  class TaskSubjectResource < JSONAPI::Resource; end
  class TaskLinkResource < JSONAPI::Resource; end

  # Defines the Task resource for the API
  class TaskResource < BaseResource
    attributes(
      :created_at,
      :description,
      :due_at,
      :finished_at,
      :state,
      :task_type,
      :title
    )

    has_one :creator, class_name: 'User'
    has_one :finisher, class_name: 'User'
    has_one :subject, polymorphic: true, class_name: 'TaskSubject'
    has_one :linked_object, polymorphic: true, class_name: 'TaskLink'

    has_many :assignees, class_name: 'User'

    filters(
      :creator_id,
      :finisher_id,
      :state
    )

    filter :state, apply: lambda { |records, value, _options|
      state = value[0]
      return records if state == 'all'

      records.where(state: state)
    }

    filter :user_id, apply: lambda { |records, value, _options|
      user_id = value[0]

      records.associated_to_user_with_id(user_id)
    }

    class << self
      def create(context)
        creator = context[:current_user]
        new(Task.new(creator: creator), context)
      end

      def updatable_fields(context)
        super(context) - %i[
          created_at
          creator
          finished
          finished_at
          finisher
          task_type
        ]
      end
    end
  end
end
