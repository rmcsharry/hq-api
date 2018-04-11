module V1
  # Defines the Contact resource for the API
  class ContactResource < JSONAPI::Resource
    model_hint model: Contact::Organization, resource: :contact
    model_hint model: Contact::Person, resource: :contact

    attributes(
      :comment,
      :commercial_register_number,
      :commercial_register_office,
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

    def self.resources_for(records, context)
      records.collect do |model|
        resource_class = resource_for_model(model)
        resource_class.new(model.decorate, context)
      end
    end
  end
end
