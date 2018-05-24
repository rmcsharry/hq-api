# frozen_string_literal: true

module V1
  # Defines the Contact resource for the API
  # rubocop:disable Metrics/ClassLength
  class ContactResource < JSONAPI::Resource
    model_hint model: Contact::Organization, resource: :contact
    model_hint model: Contact::Person, resource: :contact

    attributes(
      :comment,
      :commercial_register_number,
      :commercial_register_office,
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
    has_one :compliance_detail
    has_one :tax_detail
    has_one :primary_contact_address, class_name: 'Address'
    has_one :legal_address, class_name: 'Address'
    has_one :primary_email, class_name: 'ContactDetail'
    has_one :primary_phone, class_name: 'ContactDetail'

    # rubocop:disable Metrics/MethodLength
    def legal_address=(params)
      @model.build_legal_address(
        addition: params[:addition],
        category: params[:category] || 'home',
        city: params[:city],
        contact: @model,
        country: params[:country],
        postal_code: params[:'postal-code'],
        state: params[:state],
        street_and_number: params[:'street-and-number']
      )
      @model.primary_contact_address = @model.legal_address if @model.primary_contact_address.blank?
    end
    # rubocop:enable Metrics/MethodLength

    def primary_contact_address=(params)
      @model.build_primary_contact_address(
        addition: params[:addition],
        category: params[:category],
        city: params[:city],
        contact: @model,
        country: params[:country],
        postal_code: params[:'postal-code'],
        state: params[:state],
        street_and_number: params[:'street-and-number']
      )
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

    class << self
      def records(options)
        records = super.with_name
        unless options.dig(:context, :request_method) == 'DELETE'
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
