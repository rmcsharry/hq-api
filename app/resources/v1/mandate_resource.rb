# frozen_string_literal: true

module V1
  # Defines the Mandate resource for the API
  class MandateResource < JSONAPI::Resource
    attributes(
      :category,
      :comment,
      :datev_creditor_id,
      :datev_debitor_id,
      :mandate_number,
      :owner_name,
      :psplus_id,
      :state,
      :updated_at,
      :valid_from,
      :valid_to
    )

    has_many :mandate_members
    has_many :mandate_groups
    has_many :documents
    has_many :bank_accounts
    has_many :owners, class_name: 'MandateMember'
    has_many :mandate_groups_organizations, class_name: 'MandateGroup'
    has_many :mandate_groups_families, class_name: 'MandateGroup'
    has_one :primary_consultant, class_name: 'Contact'
    has_one :secondary_consultant, class_name: 'Contact'
    has_one :assistant, class_name: 'Contact'
    has_one :bookkeeper, class_name: 'Contact'

    filters(
      :category,
      :datev_creditor_id,
      :datev_debitor_id,
      :psplus_id,
      :state
    )

    filter :mandate_group_id, apply: lambda { |records, value, _options|
      records.joins(:mandate_groups).where('mandate_groups.id = ?', value[0])
    }

    filter :owner_name, apply: lambda { |records, value, _options|
      records.with_owner_name.where('mandates.owner_name ILIKE ?', "%#{value[0]}%")
    }

    filter :mandate_number, apply: lambda { |records, value, _options|
      records.with_owner_name.where('mandates.mandate_number ILIKE ?', "%#{value[0]}%")
    }

    filter :valid_from_min, apply: lambda { |records, value, _options|
      records.where('mandates.valid_from >= ?', Date.parse(value[0]))
    }

    filter :valid_from_max, apply: lambda { |records, value, _options|
      records.where('mandates.valid_from <= ?', Date.parse(value[0]))
    }

    filter :valid_to_min, apply: lambda { |records, value, _options|
      records.where('mandates.valid_to >= ?', Date.parse(value[0]))
    }

    filter :valid_to_max, apply: lambda { |records, value, _options|
      records.where('mandates.valid_to <= ?', Date.parse(value[0]))
    }

    filter :"primary_consultant.name", apply: lambda { |records, value, _options|
      records.joins(:primary_consultant).where(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) ILIKE ?",
        "%#{value[0]}%"
      )
    }

    filter :"secondary_consultant.name", apply: lambda { |records, value, _options|
      records.joins(:secondary_consultant).where(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) ILIKE ?",
        "%#{value[0]}%"
      )
    }

    filter :"assistant.name", apply: lambda { |records, value, _options|
      records.joins(:assistant).where(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) ILIKE ?",
        "%#{value[0]}%"
      )
    }

    filter :"bookkeeper.name", apply: lambda { |records, value, _options|
      records.joins(:bookkeeper).where(
        "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) ILIKE ?",
        "%#{value[0]}%"
      )
    }

    filter :mandate_groups_organizations, apply: lambda { |records, value, _options|
      records.joins(:mandate_groups_organizations).where('mandate_groups.name ILIKE ?', "%#{value[0]}%")
    }

    class << self
      def records(_options)
        super.with_owner_name
      end

      def resource_for(model_record, context)
        resource_klass = resource_klass_for_model(model_record)
        resource_klass.new(model_record.decorate, context)
      end

      def sortable_fields(context)
        super + %i[
          primary_consultant.name
          secondary_consultant.name
          assistant.name
          bookkeeper.name
        ]
      end
    end
  end
end
