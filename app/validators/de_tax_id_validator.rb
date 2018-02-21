# Validates German tax IDs
class DeTaxIdValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A[1-9]\d{10}\z/
    record.errors[attribute] << (options[:message] || 'is not a valid German tax ID')
  end
end
