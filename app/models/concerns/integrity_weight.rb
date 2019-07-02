# frozen_string_literal: true

  # attr_reader entity, model_key, name, relative_weight
  # attr_reader :weights

class IntegrityWeight
  WEIGHTS = [
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'date_of_birth', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'first_name', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'gender', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'last_name', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'legal_address_id', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'nationality', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'contact_person', name: 'primary_contact_address_id', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'ContactDetail::Email', name: 'primary==true', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'ContactDetail::Phone', name: 'primary==true', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'compliance_detail', name: 'kagb_classification', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'compliance_detail', name: 'occupation_role', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'compliance_detail', name: 'occupation_title', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'compliance_detail', name: 'politically_exposed', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'compliance_detail', name: 'retirement_age', relative_weight: 0.25 },
    { entity: 'Contact::Person', model_key: 'compliance_detail', name: 'wphg_classification', relative_weight: 5 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_church_tax', relative_weight: 0.25 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_health_insurance', relative_weight: 0.25 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_retirement_insurance', relative_weight: 0.25 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_tax_id', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_tax_number', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_tax_office', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'de_unemployment_insurance', relative_weight: 0.25 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'us_fatca_status', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'us_tax_form', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'tax_detail', name: 'us_tax_number', relative_weight: 1 },
    { entity: 'Contact::Person', model_key: 'documents', name: 'category==kyc', relative_weight: 10 },
    { entity: 'Contact::Person', model_key: 'activities', name: '', relative_weight: 17 }
  ].freeze
end
