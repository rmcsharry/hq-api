# frozen_string_literal: true

module V1
  # Defines the Mandate Member resource for the API
  class MandateMemberResource < BaseResource
    attributes(
      :comment,
      :member_type
    )

    has_one :contact
    has_one :mandate

    filter :contact_id
    filter :mandate_id
    filter :member_type

    filter :is_owner, apply: lambda { |records, value, _options|
      is_owner = ActiveRecord::Type::Boolean.new.cast(value[0])
      records.where("member_type #{is_owner ? '=' : '!='} 'owner'")
    }

    filter :"contact.type", apply: lambda { |records, value, _options|
      records.joins(:contact).where('contacts.type = ?', value[0])
    }

    sort :"mandate.category", apply: lambda { |records, direction, _context|
      records.left_joins(:mandate).order("mandates.category #{direction}")
    }

    sort :"mandate.owner_name", apply: lambda { |records, direction, _context|
      Mandate
        .with_owner_name
        .joins(:mandate_members)
        .merge(records)
        .order("mandates.owner_name #{direction}")
    }

    sort :"contact.name", apply: lambda { |records, direction, _context|
      records.joins(:contact).order(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) #{direction}"
      )
    }

    class << self
      def records(options)
        records = super
        return records unless options.dig(:context, :response_format) == :xlsx

        records.preload(:contact, :mandate)
      end
    end
  end
end
