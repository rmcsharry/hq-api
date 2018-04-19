# frozen_string_literal: true

# Validates iban as far as possible
class IbanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if Ibanizator.iban_from_string(value).valid? || value == ''
    record.errors[attribute] << (options[:message] || 'is not a valid IBAN')
  end
end
