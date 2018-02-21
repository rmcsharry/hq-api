module V1
  # Defines the TaxDetail resource for the API
  class TaxDetailResource < JSONAPI::Resource
    attributes(
      :de_tax_number, :de_tax_id, :de_tax_office, :de_retirement_insurance, :de_unemployment_insurance,
      :de_health_insurance, :de_church_tax, :us_tax_number, :us_tax_form, :us_fatca_status, :common_reporting_standard,
      :eu_vat_number, :legal_entity_identifier, :transparency_register
    )

    has_one :contact
    has_many :foreign_tax_numbers
  end
end