# frozen_string_literal: true

# Concern to calculate data integrity scores for an organization
module ScoreableOrganization
  extend ActiveSupport::Concern

  WEIGHT_RULES = [
    { type: 'A', model_key: 'contact_organization', name: 'commercial_register_number', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'commercial_register_office', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'legal_address_id', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'organization_category', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'organization_industry', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'organization_name', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'organization_type', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'primary_contact_address_id', relative_weight: 5 },
    { type: 'A', model_key: 'contact_organization', name: 'primary_email', relative_weight: 5 },
    { type: 'B', model_key: 'compliance_detail', name: 'kagb_classification', relative_weight: 5 },
    { type: 'B', model_key: 'compliance_detail', name: 'wphg_classification', relative_weight: 5 },
    { type: 'B', model_key: 'tax_detail', name: 'de_tax_id', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'de_tax_number', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'de_tax_office', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'legal_entity_identifier', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'transparency_register', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'us_fatca_status', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'us_tax_form', relative_weight: 1 },
    { type: 'B', model_key: 'tax_detail', name: 'us_tax_number', relative_weight: 1 },
    { type: 'C', model_key: 'documents', name: 'category==kyc', relative_weight: 10 },
    { type: 'C', model_key: 'passive_contact_relationships', name: 'role==beneficial_owner', relative_weight: 8 },
    { type: 'C', model_key: 'passive_contact_relationships', name: 'role==shareholder', relative_weight: 8 },
    { type: 'D', model_key: 'activities', name: '', relative_weight: 17 }
  ].freeze
end
