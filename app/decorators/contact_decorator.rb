# frozen_string_literal: true

# Defines the decorator for contacts
class ContactDecorator < Draper::Decorator
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
end
