# frozen_string_literal: true

module JSONAPI
  UNAUTHORIZED = '401'

  module Exceptions
    # Unauthorized error message if credentials are invalid
    class Unauthorized < Error
      def initialize(error_object_overrides = {})
        super(error_object_overrides)
      end

      def errors
        [
          create_error_object(
            code: JSONAPI::UNAUTHORIZED,
            status: :unauthorized,
            title: I18n.t('jsonapi-resources.exceptions.unauthorized.title', default: 'Unauthorized'),
            detail: I18n.t('jsonapi-resources.exceptions.unauthorized.detail', default: 'Access not authorized')
          )
        ]
      end
    end
  end
end
