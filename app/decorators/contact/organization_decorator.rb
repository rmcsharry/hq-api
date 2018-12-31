# frozen_string_literal: true

class Contact
  # Defines the decorator for organizations
  class OrganizationDecorator < ContactDecorator
    delegate_all

    alias_attribute :name, :organization_name
    alias_attribute :name_list, :organization_name

    # Returns formal salutation for the Organization
    # @return [String]
    def formal_salutation
      'Sehr geehrte Damen und Herren'
    end
  end
end
