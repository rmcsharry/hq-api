# frozen_string_literal: true

module V1
  # Defines the Address resource for the API
  class AddressResource < BaseResource
    attributes(
      :addition,
      :category,
      :city,
      :country,
      :legal_address,
      :postal_code,
      :primary_contact_address,
      :state,
      :street_and_number
    )

    has_one :contact

    filter :contact_id

    def legal_address
      @model.contact.legal_address == @model
    end

    def primary_contact_address
      @model.contact.primary_contact_address == @model
    end

    class << self
      def records(_options)
        super.includes(:contact)
      end
    end
  end
end
