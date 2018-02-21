module V1
  # Defines the ForeignTaxNumber resource for the API
  class ForeignTaxNumberResource < JSONAPI::Resource
    attributes :tax_number, :country

    has_one :tax_detail
  end
end
