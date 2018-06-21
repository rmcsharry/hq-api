# frozen_string_literal: true

# Validates roles to be included in list of available roles
class RoleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    return if values.all? { |value| UserGroup::AVAILABLE_ROLES.include? value.to_sym }
    record.errors[attribute] << (options[:message] || 'is not a set of valid roles')
  end
end
