class InitialAttributeWeights < ActiveRecord::Migration[5.2]
  def up
    person_weights = [
      person_weight('contact_person', 'date_of_birth', 5),
      person_weight('contact_person', 'first_name', 5),
      person_weight('contact_person', 'gender', 5),
      person_weight('contact_person', 'last_name', 5),
      person_weight('contact_person', 'legal_address_id', 5),
      person_weight('contact_person', 'nationality', 5),
      person_weight('contact_person', 'primary_contact_address_id', 5),
      person_weight('ContactDetail::Email', 'primary==true', 5),
      person_weight('ContactDetail::Phone', 'primary==true', 5),
      person_weight('compliance_detail', 'kagb_classification', 5),
      person_weight('compliance_detail', 'occupation_role', 1),
      person_weight('compliance_detail', 'occupation_title', 1),
      person_weight('compliance_detail', 'politically_exposed', 1),
      person_weight('compliance_detail', 'retirement_age', 0.25),
      person_weight('compliance_detail', 'wphg_classification', 5),
      person_weight('tax_detail', 'de_church_tax', 0.25),
      person_weight('tax_detail', 'de_health_insurance', 0.25),
      person_weight('tax_detail', 'de_retirement_insurance', 0.25),
      person_weight('tax_detail', 'de_tax_id', 1),
      person_weight('tax_detail', 'de_tax_number', 1),
      person_weight('tax_detail', 'de_tax_office', 1),
      person_weight('tax_detail', 'de_unemployment_insurance', 0.25),
      person_weight('tax_detail', 'us_fatca_status', 1),
      person_weight('tax_detail', 'us_tax_form', 1),
      person_weight('tax_detail', 'us_tax_number', 1),
      person_weight('documents', 'category==kyc', 10),
      person_weight('activities', '', 17)
    ]
    organization_weights = [
      organization_weight('contact_organization', 'commercial_register_number', 5),
      organization_weight('contact_organization', 'commercial_register_office', 5),
      organization_weight('contact_organization', 'de_tax_id', 1),
      organization_weight('contact_organization', 'de_tax_number', 1),
      organization_weight('contact_organization', 'de_tax_office', 1),
      organization_weight('contact_organization', 'kagb_classification', 5),
      organization_weight('contact_organization', 'legal_address_id', 5),
      organization_weight('contact_organization', 'organization_category', 5),
      organization_weight('contact_organization', 'organization_industry', 5),
      organization_weight('contact_organization', 'organization_name', 5),
      organization_weight('contact_organization', 'organization_type', 5),
      organization_weight('contact_organization', 'primary_contact_address_id', 5),
      organization_weight('contact_organization', 'transparency_register', 1),
      organization_weight('contact_organization', 'us_fatca_status', 1),
      organization_weight('contact_organization', 'us_tax_form', 1),
      organization_weight('contact_organization', 'us_tax_number', 1),
      organization_weight('contact_organization', 'wphg_classification', 5),
      organization_weight('ContactDetail::Email', 'primary==true', 5),
      organization_weight('activities', '', 17),
      organization_weight('documents', 'category==kyc', 10),
      organization_weight('passive_contact_relationships', 'role==beneficial_owner', 8),
      organization_weight('passive_contact_relationships', 'role==shareholder', 8),
      organization_weight('tax_detail', 'legal_entity_identifier', 1)      
    ]
    mandate_weights = [
      mandate_weight('mandate', 'category', 5),
      mandate_weight('mandate', 'datev_creditor_id', 1),
      mandate_weight('mandate', 'datev_debitor_id', 1),
      mandate_weight('mandate', 'mandate_number', 1),
      mandate_weight('mandate', 'psplus_id', 1),
      mandate_weight('mandate', 'state', 5),
      mandate_weight('mandate', 'valid_from', 1),
      mandate_weight('activities', '', 17),
      mandate_weight('bank_accounts', '', 5),
      mandate_weight('documents', 'category==contract_hq', 15),
      mandate_weight('mandate_members', 'member_type==assistant', 5),
      mandate_weight('mandate_members', 'member_type==bookkeeper', 5),
      mandate_weight('mandate_members', 'member_type==owner', 5),
      mandate_weight('mandate_members', 'member_type==primary_consultant', 5),
      mandate_weight('mandate_members', 'member_type==secondary_consultant', 5)      
    ]
    puts "Inserting #{person_weights.count} person weights. Total: #{person_weights.sum(&:relative_weight)}"
    AttributeWeight.import(person_weights)
    puts "Inserting #{organization_weights.count} organization weights. Total: #{organization_weights.sum(&:relative_weight)}"
    AttributeWeight.import(organization_weights)
    puts "Inserting #{mandate_weights.count}  mandate weights. Total: #{mandate_weights.sum(&:relative_weight)}"
    AttributeWeight.import(mandate_weights)

    Rake::Task['db:calculate_scores'].invoke
  end

  def down
    AttributeWeight.delete_all
    Contact.update_all(data_integrity_score: 0)
    Contact.update_all(data_integrity_missing_fields: [])
    Mandate.update_all(data_integrity_score: 0)
    Mandate.update_all(data_integrity_partial_score: 0)
    Mandate.update_all(data_integrity_missing_fields: [])
  end

  def person_weight(key, attribute, weight)
    AttributeWeight.new(entity: 'Contact::Person', model_key: key, name: attribute, relative_weight: weight)
  end

  def organization_weight(key, attribute, weight)
    AttributeWeight.new(entity: 'Contact::Organization', model_key: key, name: attribute, relative_weight: weight)
  end

  def mandate_weight(key, attribute, weight)
    AttributeWeight.new(entity: 'Mandate', model_key: key, name: attribute, relative_weight: weight)
  end
end
