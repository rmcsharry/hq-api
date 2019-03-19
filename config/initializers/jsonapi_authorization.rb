# frozen_string_literal: true

module JSONAPI
  module Authorization
    # JSONAPI::Authorization extension of the AuthorizingProcessor class
    class AuthorizingProcessor < JSONAPI::Processor
      # rubocop:disable Metrics/AbcSize
      def authorize_show_related_resource
        source_klass = params[:source_klass]
        source_id = params[:source_id]
        relationship_type = params[:relationship_type].to_sym

        source_resource = source_klass.find_by_key(source_id, context: context) # rubocop:disable Rails/DynamicFindBy

        related_resource = source_resource.try(relationship_type)

        source_record = source_resource._model
        related_record = related_resource._model unless related_resource.nil?
        authorizer.show_related_resource(source_record, related_record)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
