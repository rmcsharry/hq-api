module V1
  # Defines the Contact resource for the API
  class ContactResource < JSONAPI::Resource
    attributes(
      :first_name, :last_name, :comment, :gender, :nobility_title, :professional_title, :maiden_name,
      :date_of_birth, :date_of_death, :nationality, :organization_name, :organization_type, :organization_category,
      :organization_industry, :commercial_register_number, :commercial_register_office
    )

    has_many :addresses
    has_many :mandate_members
    has_many :documents
    has_one :compliance_detail
    has_one :tax_detail
    has_one :primary_contact_address, class_name: 'Address'
    has_one :legal_address, class_name: 'Address'
  end
end
