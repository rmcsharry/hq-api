# frozen_string_literal: true

module V1
  # Defines the Contact resource for the API
  # rubocop:disable Metrics/ClassLength
  class ContactResource < BaseResource
    model_hint model: Contact::Organization, resource: :contact
    model_hint model: Contact::Person, resource: :contact

    attributes(
      :comment,
      :commercial_register_number,
      :commercial_register_office,
      :compliance_detail,
      :contact_type,
      :date_of_birth,
      :date_of_death,
      :first_name,
      :gender,
      :last_name,
      :legal_address,
      :maiden_name,
      :name,
      :nationality,
      :nobility_title,
      :organization_category,
      :organization_industry,
      :organization_name,
      :organization_type,
      :primary_contact_address,
      :professional_title,
      :tax_detail,
      :updated_at
    )

    has_many :addresses
    has_many :contact_details
    has_many :contact_members, class_name: 'OrganizationMember'
    has_many :contacts
    has_many :documents
    has_many :mandate_members
    has_many :organization_members
    has_many :organizations, class_name: 'Contact'
    has_many :versions, relation_name: 'child_versions', class_name: 'Version'
    has_one :compliance_detail
    has_one :tax_detail
    has_one :primary_contact_address, class_name: 'Address'
    has_one :legal_address, class_name: 'Address'
    has_one :primary_email, class_name: 'ContactDetail'
    has_one :primary_phone, class_name: 'ContactDetail'

    def compliance_detail=(params)
      @model.build_compliance_detail unless @model.compliance_detail
      sanitized_params = sanitize_params(params, V1::ComplianceDetailResource)
      @model.compliance_detail.assign_attributes(sanitized_params)
      @save_needed = true
    end

    def tax_detail=(params)
      @model.build_tax_detail unless @model.tax_detail
      sanitized_params = sanitize_params(params, V1::TaxDetailResource)
      @model.tax_detail.assign_attributes(sanitized_params)
      @save_needed = true
    end

    def legal_address=(params)
      @model.build_legal_address(contact: @model) unless @model.legal_address
      sanitized_params = sanitize_params(params, V1::AddressResource)
      @model.legal_address.assign_attributes(sanitized_params)
      @save_needed = true
    end

    def primary_contact_address=(params)
      @model.build_primary_contact_address(contact: @model) unless @model.primary_contact_address
      sanitized_params = sanitize_params(params, V1::AddressResource)
      @model.primary_contact_address.assign_attributes(sanitized_params)
      @save_needed = true
    end

    filters(
      :comment,
      :commercial_register_number,
      :commercial_register_office,
      :gender,
      :nationality,
      :nobility_title,
      :organization_category,
      :organization_industry,
      :organization_type,
      :professional_title
    )

    filter :contact_type, apply: lambda { |records, value, _options|
      records.where('contacts.type = ?', value[0])
    }

    filter :date_of_birth_min, apply: lambda { |records, value, _options|
      records.where('contacts.date_of_birth >= ?', Date.parse(value[0]))
    }

    filter :date_of_birth_max, apply: lambda { |records, value, _options|
      records.where('contacts.date_of_birth <= ?', Date.parse(value[0]))
    }

    filter :date_of_death_min, apply: lambda { |records, value, _options|
      records.where('contacts.date_of_death >= ?', Date.parse(value[0]))
    }

    filter :date_of_death_max, apply: lambda { |records, value, _options|
      records.where('contacts.date_of_death <= ?', Date.parse(value[0]))
    }

    filter :name, apply: lambda { |records, value, _options|
      records.where('contacts.name ILIKE ?', "%#{value[0]}%")
    }

    filter :first_name, apply: lambda { |records, value, _options|
      records.where('contacts.first_name ILIKE ?', "%#{value[0]}%")
    }

    filter :last_name, apply: lambda { |records, value, _options|
      records.where('contacts.last_name ILIKE ?', "%#{value[0]}%")
    }

    filter :maiden_name, apply: lambda { |records, value, _options|
      records.where('contacts.maiden_name ILIKE ?', "%#{value[0]}%")
    }

    filter :organization_name, apply: lambda { |records, value, _options|
      records.where('contacts.organization_name ILIKE ?', "%#{value[0]}%")
    }

    filter :organization_category, apply: lambda { |records, value, _options|
      records.where('contacts.organization_category ILIKE ?', "%#{value[0]}%")
    }

    filter :"primary_email.value", apply: lambda { |records, value, _options|
      records.joins(:primary_email).where('contact_details.value ILIKE ?', "%#{value[0]}%")
    }

    filter :"primary_phone.value", apply: lambda { |records, value, _options|
      records.joins(:primary_phone).where('contact_details.value ILIKE ?', "%#{value[0]}%")
    }

    filter :"primary_contact_address.street_and_number", apply: lambda { |records, value, _options|
      records.joins(:primary_contact_address).where(
        "addresses.street_and_number || ', ' || addresses.postal_code || ' ' || addresses.city || ', ' || " \
        'addresses.country ILIKE ?', "%#{value[0]}%"
      )
    }

    filter :"legal_address.street_and_number", apply: lambda { |records, value, _options|
      records.joins(:legal_address).where(
        "addresses.street_and_number || ', ' || addresses.postal_code || ' ' || addresses.city || ', ' || " \
        'addresses.country ILIKE ?', "%#{value[0]}%"
      )
    }

    def fetchable_fields
      super - %i[compliance_detail tax_detail]
    end

    class << self
      def records(options)
        records = super.with_name
        if options.dig(:context, :request_method) == 'GET' &&
           options.dig(:context, :controller) != 'v1/versions'
          records = records.includes(:legal_address, :primary_contact_address)
        end
        records
      end

      def sortable_fields(context)
        super + %i[
          primary_email.value
          primary_phone.value
          primary_contact_address.street_and_number
          legal_address.street_and_number
        ]
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
