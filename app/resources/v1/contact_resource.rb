# frozen_string_literal: true

module V1
  # Defines the Contact resource for the API
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
      :maiden_name,
      :name,
      :nationality,
      :nobility_title,
      :organization_category,
      :organization_industry,
      :organization_name,
      :organization_type,
      :professional_title
    )

    has_many :addresses
    has_many :mandate_members
    has_many :documents
    has_many :contact_details
    has_one :compliance_detail
    has_one :tax_detail
    has_one :primary_contact_address, class_name: 'Address'
    has_one :legal_address, class_name: 'Address'
    has_one :primary_email, class_name: 'ContactDetail'
    has_one :primary_phone, class_name: 'ContactDetail'

    filters(
      :comment,
      :commercial_register_number,
      :commercial_register_office,
      :date_of_birth,
      :date_of_death,
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

    class << self
      def records(_options)
        super.with_name
      end

      def sortable_fields(context)
        super + %i[primary_email.value primary_phone.value primary_contact_address.street_and_number]
      end
    end
  end
end
