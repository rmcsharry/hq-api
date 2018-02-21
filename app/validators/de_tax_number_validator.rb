# Validates German tax numbers
class DeTaxNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if Steuernummer.new(value).is_valid?
    record.errors[attribute] << (options[:message] || 'is not a valid German tax number')
  end
end
