# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :db do
  desc 'Seed data integrity weights'
  task seed_weights: :environment do
    ActiveRecord::Base.transaction do
      AttributeWeight.delete_all

      puts 'Seeding contact_person weights'
      Rake::Task['db:seed_weights:contact_person'].invoke
      puts 'Seeding contact_organization weights'
      Rake::Task['db:seed_weights:contact_organization'].invoke
      puts 'Seeding mandate weights'
      Rake::Task['db:seed_weights:mandate'].invoke

      puts 'Calculating contact scores'
      Contact.all.each(&:calculate_score)
      puts 'Calculating mandate scores'
      Mandate.all.each(&:calculate_score)
    end
  end

  namespace :seed_weights do
    task contact_person: :environment do
      person_weight('contact_person', 'date_of_birth', 0.0542)
      person_weight('contact_person', 'first_name', 0.0542)
      person_weight('contact_person', 'gender', 0.0542)
      person_weight('contact_person', 'last_name', 0.0542)
      person_weight('contact_person', 'legal_address_id', 0.0542)
      person_weight('contact_person', 'nationality', 0.0542)
      person_weight('contact_person', 'primary_contact_address_id', 0.0542)
      person_weight('contact_detail', 'primary_email', 0.0542)
      person_weight('contact_detail', 'primary_phone', 0.0542)
      person_weight('compliance_detail', 'kagb_classification', 0.0542)
      person_weight('compliance_detail', 'occupation_role', 0.0108)
      person_weight('compliance_detail', 'occupation_title', 0.0108)
      person_weight('compliance_detail', 'politically_exposed', 0.0108)
      person_weight('compliance_detail', 'retirement_age', 0.0027)
      person_weight('compliance_detail', 'wphg_classification', 0.0542)
      person_weight('tax_detail', 'wphg_classification', 0.0542)
      person_weight('tax_detail', 'de_church_tax', 0.0027)
      person_weight('tax_detail', 'de_health_insurance', 0.0027)
      person_weight('tax_detail', 'de_retirement_insurance', 0.0027)
      person_weight('tax_detail', 'de_tax_id', 0.0108)
      person_weight('tax_detail', 'de_tax_number', 0.0108)
      person_weight('tax_detail', 'de_tax_office', 0.0108)
      person_weight('tax_detail', 'de_unemployment_insurance', 0.0027)
      person_weight('tax_detail', 'us_fatca_status', 0.0108)
      person_weight('tax_detail', 'us_tax_form', 0.0108)
      person_weight('tax_detail', 'us_tax_number', 0.0108)
      person_weight('documents', 'category:kyc', 0.0542)
      person_weight('activities', '', 0.17)
    end

    task contact_organization: :environment do
      organization_weight('contact_organization', 'commercial_register_number', 0.0472)
      organization_weight('contact_organization', 'commercial_register_office', 0.0472)
      organization_weight('contact_organization', 'de_tax_id', 0.0094)
      organization_weight('contact_organization', 'de_tax_number', 0.0094)
      organization_weight('contact_organization', 'de_tax_office', 0.0094)
      organization_weight('contact_organization', 'kagb_classification', 0.0472)
      organization_weight('contact_organization', 'legal_address_id', 0.0472)
      organization_weight('contact_organization', 'organization_category', 0.0472)
      organization_weight('contact_organization', 'organization_industry', 0.0472)
      organization_weight('contact_organization', 'organization_name', 0.0472)
      organization_weight('contact_organization', 'organization_type', 0.0472)
      organization_weight('contact_organization', 'primary_contact_address_id', 0.0472)
      organization_weight('contact_organization', 'primary_email', 0.0472)
      organization_weight('contact_organization', 'transparency_register', 0.0094)
      organization_weight('contact_organization', 'us_facta_status', 0.0094)
      organization_weight('contact_organization', 'us_tax_form', 0.0094)
      organization_weight('contact_organization', 'us_tax_number', 0.0094)
      organization_weight('contact_organization', 'wphg_classification', 0.0472)
      organization_weight('activities', '', 0.1604)
      organization_weight('documents', 'category:kyc', 0.0943)
      organization_weight('passive_contact_relationships', 'role:beneficial_owner', 0.0755)
      organization_weight('passive_contact_relationships', 'role:shareholder', 0.0755)
      organization_weight('tax_detail', 'legal_entity_identifier', 0.0094)
    end

    task mandate: :environment do
      mandate_weight('mandate', 'category', 0.0694)
      mandate_weight('mandate', 'datev_creditor_id', 0.0130)
      mandate_weight('mandate', 'datev_debtor_id', 0.0130)
      mandate_weight('mandate', 'mandate_number', 0.0130)
      mandate_weight('mandate', 'psplus_id', 0.0130)
      mandate_weight('mandate', 'state', 0.0649)
      mandate_weight('mandate', 'valid_from', 0.0130)
      mandate_weight('activities', '', 0.2208)
      mandate_weight('bank_accounts', '', 0.0649)
      mandate_weight('documents', 'category:contract_hq', 0.1948)
      mandate_weight('mandate_members', 'member_type:assistant', 0.0649)
      mandate_weight('mandate_members', 'member_type:bookkeeper', 0.0649)
      mandate_weight('mandate_members', 'member_type:owner', 0.0649)
      mandate_weight('mandate_members', 'member_type:primary_consultant', 0.0649)
      mandate_weight('mandate_members', 'member_type:secondary_consultant', 0.0649)
    end

    def person_weight(key, attribute, weight)
      AttributeWeight.create(entity: 'Contact::Person', model_key: key, name: attribute, value: weight)
    end

    def organization_weight(key, attribute, weight)
      AttributeWeight.create(entity: 'Contact::Organization', model_key: key, name: attribute, value: weight)
    end

    def mandate_weight(key, attribute, weight)
      AttributeWeight.create(entity: 'Mandate', model_key: key, name: attribute, value: weight)
    end
  end
end
# rubocop:enable Metrics/BlockLength
