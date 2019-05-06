# frozen_string_literal: true

module V1
  class TaskSubjectResource < JSONAPI::Resource; end
  class TaskLinkResource < JSONAPI::Resource; end

  # Defines the Task resource for the API
  class TaskResource < BaseResource
    custom_action :finish, type: :patch, level: :instance
    custom_action :unfinish, type: :patch, level: :instance

    attributes(
      :created_at,
      :description,
      :due_at,
      :finished_at,
      :task_comment_count,
      :state,
      :task_type,
      :title
    )

    has_one :creator, class_name: 'User'
    has_one :finisher, class_name: 'User'
    has_one :subject, polymorphic: true, class_name: 'TaskSubject'
    has_one :linked_object, polymorphic: true, class_name: 'TaskLink'

    has_many :assignees, class_name: 'User'
    has_many :task_comments

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

    def finish(_data)
      @model.finish(context[:current_user])
      @model
    end

    def unfinish(_data)
      @model.unfinish
      @model
    end

    def task_comment_count
      @model.task_comments.count
    end

    class << self
      def count(filters, options = {})
        filter_records(filters, options).count
      end

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
          task_comment_count
          task_type
        ]
      end
    end
  end
end
