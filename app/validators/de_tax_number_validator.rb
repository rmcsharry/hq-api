# frozen_string_literal: true

# Validates German tax numbers
class DeTaxNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value && Steuernummer.new(value).is_valid?

    record.errors[attribute] << (options[:message] || 'is not a valid German tax number')
  end
end
