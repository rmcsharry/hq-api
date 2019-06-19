# frozen_string_literal: true

# Defines the decorator for contacts
class ContactDecorator < ApplicationDecorator
  # Returns concatenated tax_numbers of the contact
  # @return [String]
  # rubocop:disable Metrics/AbcSize
  def tax_numbers
    tax_numbers = tax_detail.foreign_tax_numbers.map do |foreign_tax_number|
      "#{foreign_tax_number.country} #{foreign_tax_number.tax_number}"
    end
    tax_numbers.unshift "US #{tax_detail.us_tax_number}" if tax_detail.us_tax_number.present?
    tax_numbers.unshift "DE #{tax_detail.de_tax_number}" if tax_detail.de_tax_number.present?

    tax_numbers.join(', ')
  end
  # rubocop:enable Metrics/AbcSize

  # Returns only the name for organizations
  # @return [String]
  def name_with_gender
    name
  end

  def data_integrity_score
    # format_percentage(object.data_integrity_score * 100)
    helpers.number_to_percentage(object.data_integrity_score * 100, precision: 0, format: '%n')
  end
end
