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
    end
  end
end
