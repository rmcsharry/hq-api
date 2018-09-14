# frozen_string_literal: true

class Contact
  # Defines the decorator for organizations
  class OrganizationDecorator < ContactDecorator
    delegate_all

    alias_attribute :name, :organization_name
    alias_attribute :name_list, :organization_name
  end
end
