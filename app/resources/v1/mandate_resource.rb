# frozen_string_literal: true

module V1
  # Defines the Mandate resource for the API
  # rubocop:disable Metrics/ClassLength
  class MandateResource < BaseResource
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

    has_many :bank_accounts
    has_many :documents
    has_many :mandate_groups
    has_many :mandate_groups_families, class_name: 'MandateGroup'
    has_many :mandate_groups_organizations, class_name: 'MandateGroup'
    has_many :mandate_members
    has_many :owners, class_name: 'MandateMember'
    has_many :versions, relation_name: 'child_versions', class_name: 'Version'
    has_one :assistant, class_name: 'Contact'
    has_one :bookkeeper, class_name: 'Contact'
    has_one :primary_consultant, class_name: 'Contact'
    has_one :secondary_consultant, class_name: 'Contact'

    def owner_ids=(relationship_key_values)
      relationship_key_values.each do |key|
        @model.owners << MandateMember.new(member_type: 'owner', contact: Contact.find(key))
      end
    end

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
      owner_name, category = value[0]&.split('–', 2)
      category = value[1] if value[1].present?
      records = records.with_owner_name.where('mandates.owner_name ILIKE ?', "%#{owner_name&.strip}%")
      return records unless category
      categories = Mandate.category.values.map { |v| [v.text, v] }.to_h
      possible_categories = categories.select { |key| key.downcase.include? category.strip.downcase }.values
      records.where(category: possible_categories)
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

    filter :user_id, apply: lambda { |records, value, _options|
      contact = User.find_by(id: value[0])&.contact
      return records.none unless contact
      records.where(
        primary_consultant: contact
      ).or(
        records.where(secondary_consultant: contact)
      ).or(
        records.where(assistant: contact)
      ).or(
        records.where(bookkeeper: contact)
      )
    }

    filter :mandate_groups_organizations, apply: lambda { |records, value, _options|
      records.joins(:mandate_groups_organizations).where('mandate_groups.name ILIKE ?', "%#{value[0]}%")
    }

    sort :"primary_consultant.name", apply: lambda { |records, direction, _context|
      order_by_name_of_contact(records.joins(:primary_consultant), direction)
    }

    sort :"secondary_consultant.name", apply: lambda { |records, direction, _context|
      order_by_name_of_contact(records.joins(:secondary_consultant), direction)
    }

    sort :"assistant.name", apply: lambda { |records, direction, _context|
      order_by_name_of_contact(records.joins(:assistant), direction)
    }

    sort :"bookkeeper.name", apply: lambda { |records, direction, _context|
      order_by_name_of_contact(records.joins(:bookkeeper), direction)
    }

    sort :owner_name, apply: lambda { |records, direction, _context|
      records.includes(:owners).with_owner_name.order("mandates.owner_name #{direction}")
    }

    class << self
      def records(options)
        records = super
        if options.dig(:context, :request_method) == 'POST' && options.dig(:context, :controller) == 'v1/activities'
          records = records.includes(:mandate_groups_organizations)
        end
        records
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

      private

      def order_by_name_of_contact(records, direction)
        records.order(
          "COALESCE(contacts.first_name || ' ' || contacts.last_name, contacts.organization_name) #{direction}"
        )
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
