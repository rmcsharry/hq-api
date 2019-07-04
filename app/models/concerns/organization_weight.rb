# frozen_string_literal: true

# Concern to provide weight inputs to calculate data integrity scores for an organization
module OrganizationWeight
  extend ActiveSupport::Concern

  WEIGHT_RULES = [
    { model_key: 'contact_organization', name: 'commercial_register_number', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'commercial_register_office', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'de_tax_id', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'de_tax_number', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'de_tax_office', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'kagb_classification', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'legal_address_id', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'organization_category', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'organization_industry', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'organization_name', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'organization_type', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'primary_contact_address_id', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'transparency_register', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'us_fatca_status', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'us_tax_form', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'us_tax_number', relative_weight: 1 },
    { model_key: 'contact_organization', name: 'wphg_classification', relative_weight: 5 },
    { model_key: 'contact_organization', name: 'primary_email', relative_weight: 5 },
    { model_key: 'activities', name: '', relative_weight: 17 },
    { model_key: 'documents', name: 'category==kyc', relative_weight: 10 },
    { model_key: 'passive_contact_relationships', name: 'role==beneficial_owner', relative_weight: 8 },
    { model_key: 'passive_contact_relationships', name: 'role==shareholder', relative_weight: 8 },
    { model_key: 'tax_detail', name: 'legal_entity_identifier', relative_weight: 1 }
  ].freeze
end
