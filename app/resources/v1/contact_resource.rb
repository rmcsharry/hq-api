# frozen_string_literal: true

module V1
  # Defines the Contact resource for the API
  # rubocop:disable Metrics/ClassLength
  class ContactResource < BaseResource
    attributes(
      :addresses,
      :comment,
      :commercial_register_number,
      :commercial_register_office,
      :compliance_detail,
      :contact_details,
      :contact_type,
      :data_integrity_score,
      :data_integrity_missing_fields,
      :date_of_birth,
      :date_of_death,
      :first_name,
      :gender,
      :is_mandate_member,
      :is_mandate_owner,
      :last_name,
      :legal_address,
      :legal_address_text,
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
      :primary_contact_address_text,
      :professional_title,
      :tax_detail,
      :updated_at
    )

    has_many :active_contact_relationships, class_name: 'ContactRelationship'
    has_many :addresses
    has_many :contact_details
    has_many :documents
    has_many :investors
    has_many :mandate_members
    has_many :passive_contact_relationships, class_name: 'ContactRelationship'
    has_many :versions, relation_name: 'child_versions', class_name: 'Version'
    has_one :compliance_detail
    has_one :legal_address, class_name: 'Address'
    has_one :primary_contact_address, class_name: 'Address'
    has_one :primary_email, class_name: 'ContactDetail'
    has_one :primary_phone, class_name: 'ContactDetail'
    has_one :tax_detail

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

    def addresses=(params)
      params.each do |address_params|
        address = @model.addresses.build(owner: @model)
        sanitized_params = sanitize_params(address_params, V1::AddressResource)
        address.assign_attributes(sanitized_params)
      end
      @save_needed = true
    end

    def contact_details=(params)
      params.each do |contact_detail_params|
        contact_detail = @model.contact_details.build(contact: @model)
        sanitized_params = sanitize_params(contact_detail_params, V1::ContactDetailResource)
        contact_detail.assign_attributes(sanitized_params)
      end
      @save_needed = true
    end

    def data_integrity_score
      @model.decorate.data_integrity_score
    end

    def name_list
      @model.decorate.name_list
    end

    def name
      @model.decorate.name
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

    filter :mandate_id, apply: lambda { |records, value, _options|
      mandate_id = value[0]
      records.associated_to_mandate_with_id(mandate_id)
    }

    filter :mandate_member_by_mandate_id_and_type, apply: lambda { |records, value, _options|
      mandate_id = value[0]
      member_type = value[1]

      records
        .joins(:mandate_members)
        .where('mandate_members.mandate_id = ?', mandate_id)
        .where('mandate_members.member_type = ?', member_type)
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
      normalized_number = PhonyRails.normalize_number(value[0])
      records.joins(:primary_phone).where('contact_details.value ILIKE ?', "%#{normalized_number}%")
    }

    filter :"phone.value", apply: lambda { |records, value, _options|
      normalized_number = PhonyRails.normalize_number(value[0])
      records.where(
        id: ContactDetail::Phone.select(:contact_id).where('value ILIKE ?', "%#{normalized_number}%")
      )
    }

    filter :"fax.value", apply: lambda { |records, value, _options|
      normalized_number = PhonyRails.normalize_number(value[0])
      records.where(
        id: ContactDetail::Fax.select(:contact_id).where('value ILIKE ?', "%#{normalized_number}%")
      )
    }

    filter :"email.value", apply: lambda { |records, value, _options|
      records.where(
        id: ContactDetail::Email.select(:contact_id).where('value ILIKE ?', "%#{value[0]}%")
      )
    }

    filter :primary_contact_address_text, apply: lambda { |records, value, _options|
      records
        .joins(
          'INNER JOIN addresses AS pa ON contacts.primary_contact_address_id = pa.id'
        ).where(
          "CONCAT_WS(', ', pa.organization_name, pa.street_and_number, pa.postal_code, pa.city, pa.country) ILIKE ?",
          "%#{value[0]}%"
        )
    }

    filter :legal_address_text, apply: lambda { |records, value, _options|
      records
        .joins(
          'INNER JOIN addresses AS la ON contacts.legal_address_id = la.id'
        ).where(
          "CONCAT_WS(', ', la.organization_name, la.street_and_number, la.postal_code, la.city, la.country) ILIKE ?",
          "%#{value[0]}%"
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

    filter :not_in_list_with_id, apply: lambda { |records, value, _options|
      records.where(%(contacts.id NOT IN (
        SELECT list_items.listable_id FROM list_items
        WHERE list_items.list_id = ? AND list_items.listable_type = 'Contact'
      )), value)
    }

    sort :primary_contact_address_text, apply: lambda { |records, direction, _context|
      records
        .joins(
          'INNER JOIN addresses AS pca ON contacts.primary_contact_address_id = pca.id'
        ).order(
          "CONCAT(pca.organization_name, pca.street_and_number, pca.postal_code, pca.city, pca.country) #{direction}"
        )
    }

    sort :legal_address_text, apply: lambda { |records, direction, _context|
      records
        .joins(
          'INNER JOIN addresses AS la ON contacts.legal_address_id = la.id'
        ).order(
          "CONCAT(la.organization_name, la.street_and_number, la.postal_code, la.city, la.country) #{direction}"
        )
    }

    sort :"compliance_detail.occupation_role", apply: lambda { |records, direction, _context|
      records.joins(:compliance_detail).order("compliance_details.occupation_role #{direction}")
    }

    sort :"compliance_detail.occupation_title", apply: lambda { |records, direction, _context|
      records.joins(:compliance_detail).order("compliance_details.occupation_title #{direction}")
    }

    sort :is_mandate_owner, apply: lambda { |records, direction, _context|
      records.joins(
        "
          LEFT JOIN (
            SELECT contact_id AS contact_id, COUNT(*) > 0
            FROM mandate_members
            WHERE member_type = 'owner'
            GROUP BY contact_id
          ) mandate_member_counts
          ON contacts.id = mandate_member_counts.contact_id
        "
      ).order("mandate_member_counts #{direction}")
    }

    sort :is_mandate_member, apply: lambda { |records, direction, _context|
      records.joins(
        "
          LEFT JOIN (
            SELECT contact_id AS contact_id, COUNT(*) > 0
            FROM mandate_members
            GROUP BY contact_id
          ) mandate_member_counts
          ON contacts.id = mandate_member_counts.contact_id
        "
      ).order("mandate_member_counts #{direction}")
    }

    def fetchable_fields
      super - %i[addresses contact_details compliance_detail tax_detail]
    end

    def fetchable_relationships
      super + %i[addresses contact_details compliance_detail tax_detail]
    end

    class << self
      def records(options)
        records = super.with_name
        if options.dig(:context, :request_method) == 'GET' &&
           options.dig(:context, :controller) != 'v1/versions'
          records = records.includes(:primary_contact_address, :legal_address, :mandate_members)
        end
        return records unless options.dig(:context, :response_format) == :xlsx

        records.preload(
          :tax_detail, :compliance_detail, :contact_details, :addresses, :mandates, :primary_email, :primary_phone
        )
      end

      def sortable_fields(context)
        super + %i[
          legal_address_text
          primary_contact_address_text
          primary_email.value
          primary_phone.value
        ]
      end

      def create(context)
        new(create_model(context), context)
      end

      def create_model(context)
        find_klass(type: context[:type]).new
      end

      def updatable_fields(context)
        super(context) - %i[
          is_mandate_member is_mandate_owner legal_address_text primary_contact_address_text addresses contact_details
        ]
      end

      private

      def find_klass(type:)
        klass = Contact.subclasses.find { |k| k.name == type }
        raise JSONAPI::Exceptions::InvalidFieldValue.new('contact-type', type) unless klass

        klass
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
