# frozen_string_literal: true

module V1
  # Defines the ForeignTaxNumber resource for the API
  class ForeignTaxNumberResource < BaseResource
    attributes :tax_number, :country

    has_one :tax_detail

    filter :tax_detail_id

    filter :"tax_detail.contact_id", apply: lambda { |records, value, _options|
      records.joins(:tax_detail).where('tax_details.contact_id = ?', value[0])
    }

    class << self
      def records(options)
        super.preload(:tax_detail)
      end
    end
  end
end
