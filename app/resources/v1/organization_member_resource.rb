# frozen_string_literal: true

module V1
  # Defines the Organization Member resource for the API
  class OrganizationMemberResource < BaseResource
    attributes(:role)

    has_one :contact
    has_one :organization, class_name: 'Contact'

    filters(
      :contact_id,
      :organization_id
    )

    sort :"organization.name", apply: lambda { |records, direction, _context|
      records.joins(:organization).order("contacts.organization_name #{direction}")
    }
  end
end
