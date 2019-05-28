# frozen_string_literal: true

module V1
  # Defines the contact relationship resource for the API
  class ContactRelationshipResource < BaseResource
    attributes(
      :comment,
      :role
    )

    has_one :source_contact, class_name: 'Contact'
    has_one :target_contact, class_name: 'Contact'

    filters(
      :source_contact_id,
      :target_contact_id
    )

    filter :contact_id, apply: lambda { |records, value, _options|
      contact_id = value.first
      records
        .where(source_contact_id: contact_id)
        .or(
          records.where(target_contact_id: contact_id)
        )
    }

    filter :indirectly_associating_mandates_to_contact_with_id, apply: lambda { |records, value, _options|
      contact_id = value.first

      records.indirectly_associating_mandates_to_contact_with_id(contact_id)
    }

    filter :'source_contact.type', apply: lambda { |records, value, _options|
      records
        .joins('LEFT JOIN contacts AS source_contacts ON contact_relationships.source_contact_id = source_contacts.id')
        .where('source_contacts.type = ?', value[0])
    }

    filter :'target_contact.type', apply: lambda { |records, value, _options|
      records
        .joins('LEFT JOIN contacts AS target_contacts ON contact_relationships.target_contact_id = target_contacts.id')
        .where('target_contacts.type = ?', value[0])
    }

    sort :target_contact, apply: lambda { |records, direction, _context|
      records.joins('LEFT OUTER JOIN contacts AS targets ON targets.id = contact_relationships.target_contact_id')
             .order(
               "(targets.last_name || ', ' || targets.first_name) #{direction}"
             )
    }
  end
end
