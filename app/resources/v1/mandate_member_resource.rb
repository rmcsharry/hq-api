# frozen_string_literal: true

module V1
  # Defines the Mandate Member resource for the API
  class MandateMemberResource < BaseResource
    attributes(:member_type, :start_date, :end_date)

    has_one :contact
    has_one :mandate

    filter :contact_id
    filter :mandate_id

    filter :is_owner, apply: lambda { |records, value, _options|
      is_owner = ActiveRecord::Type::Boolean.new.cast(value[0])
      records.where("member_type #{is_owner ? '=' : '!='} 'owner'")
    }

    sort :"mandate.category", apply: lambda { |records, direction, _context|
      records.joins(:mandate).order("mandates.category #{direction}")
    }

    sort :"mandate.owner_name", apply: lambda { |records, direction, _context|
      records
        .merge(Mandate.with_owner_name)
        .joins('LEFT OUTER JOIN mandate_members as mandate_members ON mandates.id = mandate_members.mandate_id')
        .order("mandates.owner_name #{direction}")
    }

    sort :"contact.name", apply: lambda { |records, direction, _context|
      records.joins(:contact).order(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) #{direction}"
      )
    }
  end
end
