# frozen_string_literal: true

module V1
  # Defines the TaxDetail resource for the API
  class TaxDetailResource < BaseResource
    attributes(
      :de_tax_number, :de_tax_id, :de_tax_office, :de_retirement_insurance, :de_unemployment_insurance,
      :de_health_insurance, :de_church_tax, :us_tax_number, :us_tax_form, :us_fatca_status, :common_reporting_standard,
      :eu_vat_number, :legal_entity_identifier, :transparency_register
    )

    has_one :contact
    has_many :foreign_tax_numbers

    class << self
      def records(options)
        records = super
        records = records.preload(:contact) if options.dig(:context, :request_method) == 'GET'
        records
      end
    end
  end
end
