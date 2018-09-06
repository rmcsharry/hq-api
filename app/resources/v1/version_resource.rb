# frozen_string_literal: true

module V1
  # Defines the Version resource for the API
  class VersionResource < BaseResource
    attributes(
      :changed_by,
      :changes,
      :created_at,
      :event,
      :item_id,
      :item_type,
      :parent_item_id
    )

    def changed_by
      @model.user&.contact&.decorate&.name
    end

    def changes
      @model.changes.transform_keys(&:dasherize)
    end

    def item_type
      resource_klass._type.to_s.dasherize
    end

    private

    def resource_klass
      self.class.resource_klass_for(@model.item_type)
    end

    class << self
      def records(_options)
        super.includes(:item, user: :contact)
      end

      def updatable_fields(_context)
        []
      end
    end
  end
end
