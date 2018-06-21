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
  end
end
