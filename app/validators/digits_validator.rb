# frozen_string_literal: true

# Validates number only strings (ie. strings that are integers > 0) as follows:
# Expectations:
#  - provide the option :exactly (specifies the exact length x of the string)
# Results:
#  - invalid: string contains all 0
#  - valid: string contains exactly x digits (except all 0)
class DigitsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    length = options[:exactly]
    raise ActiveRecord::RecordInvalid if length.nil?

    regex = /\A(?!0{#{length}})\d{#{length}}\z/
    return unless value.scan(regex).empty?

    record.errors[attribute] <<
      (options[:message] || I18n.t('activerecord.errors.custom.digits_attr_invalid', length: length))
  end
end
