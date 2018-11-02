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

    has_one :owner, polymorphic: true

    filter :owner_id

    def legal_address
      @model.owner.legal_address == @model
    end

    def primary_contact_address
      @model.owner.primary_contact_address == @model
    end

    # TODO: Can be removed when this issue is solved: https://github.com/cerebris/jsonapi-resources/issues/1160
    def _replace_polymorphic_to_one_link(relationship_type, key_value, key_type, _options)
      relationship = self.class._relationships[relationship_type.to_sym]

      send("#{relationship.foreign_key}=", type: self.class.model_name_for_type(key_type), id: key_value)
      @save_needed = true

      :completed
    end

    class << self
      def records(options)
        super.preload(:owner)
      end
    end
  end
end
