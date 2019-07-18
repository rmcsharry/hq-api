# frozen_string_literal: true

# Concern to calculate data integrity scores for a person
module ScoreablePerson
  extend ActiveSupport::Concern

  included do
    # after_add_for_activities << lambda do |_hook, contact, _activity|
    #   rule = get_rule(model_key: 'activities', name: '')
    #   process_single_rule(instance: contact, rule: rule) if contact.activities.count == 1
    # end
    # after_remove_for_activities << lambda do |_hook, contact, _activity|
    #   rule = get_rule(model_key: 'activities', name: '')
    #   process_single_rule(instance: contact, rule: rule) if contact.activities.count.zero?
    # end
  end

  WEIGHT_RULES = [
    { type: 'MainProperty', model_key: 'contact_person', name: 'date_of_birth', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'first_name', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'gender', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'last_name', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'legal_address_id', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'nationality', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'primary_contact_address_id', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'primary_email', relative_weight: 5 },
    { type: 'MainProperty', model_key: 'contact_person', name: 'primary_phone', relative_weight: 5 },
    { type: 'RelativeProperty', model_key: 'compliance_detail', name: 'kagb_classification', relative_weight: 5 },
    { type: 'RelativeProperty', model_key: 'compliance_detail', name: 'occupation_role', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'compliance_detail', name: 'occupation_title', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'compliance_detail', name: 'politically_exposed', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'compliance_detail', name: 'retirement_age', relative_weight: 0.25 },
    { type: 'RelativeProperty', model_key: 'compliance_detail', name: 'wphg_classification', relative_weight: 5 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_church_tax', relative_weight: 0.25 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_health_insurance', relative_weight: 0.25 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_retirement_insurance', relative_weight: 0.25 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_tax_id', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_tax_number', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_tax_office', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'de_unemployment_insurance', relative_weight: 0.25 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'us_fatca_status', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'us_tax_form', relative_weight: 1 },
    { type: 'RelativeProperty', model_key: 'tax_detail', name: 'us_tax_number', relative_weight: 1 },
    { type: 'RelativeFieldValue', model_key: 'documents', name: 'category==kyc', relative_weight: 10 },
    { type: 'RelativeAtLeastOne', model_key: 'activities', name: '', relative_weight: 17 }
  ].freeze
end
