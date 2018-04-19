# frozen_string_literal: true

class Contact
  # Defines the decorator for organizations
  class OrganizationDecorator < ContactDecorator
    delegate_all

    alias_attribute :name, :organization_name
  end
end
