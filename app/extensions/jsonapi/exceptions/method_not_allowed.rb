# frozen_string_literal: true

module JSONAPI
  METHOD_NOT_ALLOWED = '405'

  module Exceptions
    # ActiveRecord::ReadOnlyRecord
    class MethodNotAllowed < Error
      def initialize(error_object_overrides = {})
        super(error_object_overrides)
      end

      def errors
        [
          create_error_object(
            code: JSONAPI::METHOD_NOT_ALLOWED,
            status: :method_not_allowed,
            source: { pointer: '' },
            title: 'Method not allowed',
            detail: 'The record is read-only'
          )
        ]
      end
    end
  end
end
