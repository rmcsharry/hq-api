# frozen_string_literal: true

module V1
  # Defines the Contact Detail resource for the API
  class ContactDetailResource < BaseResource
    attributes(
      :category,
      :contact_detail_type,
      :primary,
      :value
    )

    has_one :contact

    filters(
      :contact_id,
      :contact_detail_type
    )

    class << self
      def records(options)
        super.preload(:contact)
      end

      def resource_for(model_record, context)
        type = context[:type]
        if type && context[:controller] == 'v1/contact-details'
          klass = find_klass(type: type)
          model_record = model_record.becomes(klass) if klass != model_record.type
        end
        super
      end

      def create(context)
        new(create_model(context), context)
      end

      def create_model(context)
        find_klass(type: context[:type]).new
      end

      private

      def find_klass(type:)
        klass = ContactDetail.subclasses.find { |k| k.name == type }
        raise JSONAPI::Exceptions::InvalidFieldValue.new('contact-detail-type', type) unless klass

        klass
      end
    end
  end
end
