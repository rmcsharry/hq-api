# frozen_string_literal: true

module V1
  # Defines the Tasks controller
  class TasksController < ApplicationController
    before_action :authenticate_user!

    def finish
      begin
        @response_document = create_response_document
        task = Task.find(params.require(:id))
        authorize task, :update?

        task.finish(current_user)
        generate_task_response(task: task)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def unfinish
      begin
        @response_document = create_response_document
        task = Task.find(params.require(:id))
        authorize task, :update?

        task.unfinish
        generate_task_response(task: task)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    private

    def generate_task_response(task:, serializer: JSONAPI::ResourceSerializer.new(TaskResource))
      resource_set = create_resource_set(task: task)
      result = JSONAPI::ResourceSetOperationResult.new(:ok, resource_set)
      operation = JSONAPI::Operation.new(
        :show,
        TaskResource,
        serializer: serializer
      )
      response_document.add_result(result, operation)
    end

    def create_resource_set(task:)
      {
        'TaskResource' => {
          task.id => {
            primary: true,
            resource: TaskResource.new(task, nil),
            relationships: {}
          }
        }
      }
    end
  end
end
