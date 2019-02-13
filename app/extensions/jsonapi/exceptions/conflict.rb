# frozen_string_literal: true

module JSONAPI
  CONFLICT = '409'

  module Exceptions
    # ActiveRecord::InvalidForeignKey
    class Conflict < Error
      def initialize(error_object_overrides = {})
        super(error_object_overrides)
      end

      def errors
        [
          create_error_object(
            code: JSONAPI::CONFLICT,
            status: :conflict,
            source: { pointer: '' },
            title: 'Conflict',
            detail: 'Foreign key violation'
          )
        ]
      end
    end
  end
end
