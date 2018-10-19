# frozen_string_literal: true

module JSONAPI
  FORBIDDEN = '403'

  module Exceptions
    # Unauthorized error message if credentials are invalid
    class DeactivateSelf < Error
      def initialize(error_object_overrides = {})
        super(error_object_overrides)
      end

      def errors
        [
          create_error_object(
            code: JSONAPI::FORBIDDEN,
            status: :forbidden,
            title: I18n.t('jsonapi-resources.exceptions.deactivate_self.title', default: 'Forbidden'),
            detail: I18n.t('jsonapi-resources.exceptions.deactivate_self.detail', default: 'Cannot deactivate yourself')
          )
        ]
      end
    end
  end
end
