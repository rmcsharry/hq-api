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
      :is_mandate_member,
      :is_mandate_owner,
      :last_name,
      :legal_address,
      :maiden_name,
      :name,
      :name_list,
      :nationality,
      :nobility_title,
      :organization_category,
      :organization_industry,
      :organization_name,
      :organization_type,
      :place_of_birth,
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
      @model.build_legal_address(owner: @model) unless @model.legal_address
      sanitized_params = sanitize_params(params, V1::AddressResource)
      @model.legal_address.assign_attributes(sanitized_params)
      @save_needed = true
    end

    def primary_contact_address=(params)
      @model.build_primary_contact_address(owner: @model) unless @model.primary_contact_address
      sanitized_params = sanitize_params(params, V1::AddressResource)
      @model.primary_contact_address.assign_attributes(sanitized_params)
      @save_needed = true
    end

    filters(
      :comment,
      :commercial_register_number,
      :commercial_register_office,
      :gender,
      :is_mandate_member,
      :is_mandate_owner,
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

    filter :place_of_birth, apply: lambda { |records, value, _options|
      records.where('contacts.place_of_birth ILIKE ?', "%#{value[0]}%")
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

    filter :name_list, apply: lambda { |records, value, _options|
      search_string = value.join(',')
      records.where('contacts.name_list ILIKE ?', "%#{search_string}%")
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

    filter :"compliance_detail.occupation_role", apply: lambda { |records, value, _options|
      records.joins(:compliance_detail).where('compliance_details.occupation_role = ?', value[0])
    }

    filter :"compliance_detail.occupation_title", apply: lambda { |records, value, _options|
      records.joins(:compliance_detail).where('compliance_details.occupation_title ILIKE ?', "%#{value[0]}%")
    }

    filter :is_mandate_owner, apply: lambda { |records, value, _options|
      return records if value[0] == 'none'

      ids = MandateMember.select(:contact_id).where(member_type: 'owner')
      if ActiveModel::Type::Boolean.new.cast(value[0])
        records.where(id: ids)
      else
        records.where.not(id: ids)
      end
    }

    filter :is_mandate_member, apply: lambda { |records, value, _options|
      return records if value[0] == 'none'

      ids = MandateMember.select(:contact_id)
      if ActiveModel::Type::Boolean.new.cast(value[0])
        records.where(id: ids)
      else
        records.where.not(id: ids)
      end
    }

    def fetchable_fields
      super - %i[compliance_detail tax_detail]
    end

    def fetchable_relationships
      super + %i[compliance_detail tax_detail]
    end

    class << self
      def records(options)
        records = super.with_name
        if options.dig(:context, :request_method) == 'GET' &&
           options.dig(:context, :controller) != 'v1/versions'
          records = records.includes(:primary_contact_address, :legal_address, :mandate_members)
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

      def create(context)
        new(create_model(context), context)
      end

      def create_model(context)
        type = context[:type]
        raise JSONAPI::Exceptions::InvalidFieldValue.new('contact-type', type) unless valid_type?(type: type)

        type.new
      end

      def updatable_fields(context)
        super(context) - %i[is_mandate_member is_mandate_owner]
      end

      private

      def valid_type?(type:)
        Contact.subclasses.include? type
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
