# frozen_string_literal: true

module V1
  # Defines the inter-person relationship resource for the API
  class InterPersonRelationshipResource < BaseResource
    attributes(:role)

    has_one :source_person, class_name: 'Contact'
    has_one :target_person, class_name: 'Contact'

    filters(
      :source_person_id,
      :target_person_id
    )

    filter :person_id, apply: lambda { |records, value, _options|
      person_id = value.first
      records
        .where(source_person_id: person_id)
        .or(
          records.where(target_person_id: person_id)
        )
    }

    sort :target_person, apply: lambda { |records, direction, _context|
      records.joins('LEFT OUTER JOIN contacts AS targets ON targets.id = inter_person_relationships.target_person_id')
             .order(
               "(targets.last_name || ', ' || targets.first_name) #{direction}"
             )
    }
  end
end
