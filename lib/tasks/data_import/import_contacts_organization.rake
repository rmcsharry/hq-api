# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import contacts (organization)'
  task :import_contacts_organization, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    organization_types = Contact::Organization.organization_type.values.map { |v| [v.text, v] }.to_h

    wphg_classifications = ComplianceDetail.wphg_classification.values.map { |v| [v.text, v] }.to_h
    kagb_classifications = ComplianceDetail.kagb_classification.values.map { |v| [v.text, v] }.to_h

    us_tax_forms = TaxDetail.us_tax_form.values.map { |v| [v.text, v] }.to_h
    us_fatca_statuses = TaxDetail.us_fatca_status.values.map { |v| [v.text, v] }.to_h

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts "Parsing contact #{row['id']}"
        contact = Contact::Organization.create!(
          import_id: row['id'],
          organization_name: row['organization_name'],
          organization_type: organization_types[row['organization_type']],
          organization_category: row['organization_category']&.split(',')&.join(', '),
          organization_industry: row['organization_industry'],
          commercial_register_number: row['commercial_register_number'],
          commercial_register_office: row['commercial_register_office'],
          comment: row['comment']
        )
        ComplianceDetail.new(
          contact: contact,
          wphg_classification: wphg_classifications[row['wphg_classification']],
          kagb_classification: kagb_classifications[row['kagb_classification']]
        ).save(validate: false)
        TaxDetail.new(
          contact: contact,
          common_reporting_standard: row['common_reporting_standard'] == 'Ja',
          de_tax_id: row['de_tax_id'],
          de_tax_number: row['de_tax_number'],
          eu_vat_number: row['eu_vat_number'],
          legal_entity_identifier: row['legal_entity_identifier'],
          transparency_register: row['transparency_register'] == 'Ja',
          us_fatca_status: us_fatca_statuses[row['us_fatca_status']],
          us_tax_form: us_tax_forms[row['us_tax_form']],
          us_tax_number: row['us_tax_number']
        ).save(validate: false)
        row['foreign_tax_ids']&.split(',')&.each do |foreign_tax_id|
          contact.tax_detail.foreign_tax_numbers.create!(
            country: foreign_tax_id[0..1],
            tax_number: foreign_tax_id[3..-1]
          )
        end
        if row['street_and_number_legal']
          legal_address = contact.addresses.create!(
            street_and_number: row['street_and_number_legal'],
            addition: row['addition_legal'],
            postal_code: row['postal_code_legal'],
            city: row['city_legal'],
            country: row['country_legal'] ? row['country_legal'] : 'DE'
          )
          contact.legal_address = legal_address
          contact.primary_contact_address = legal_address
        end
        if row['street_and_number_primary']
          primary_address = contact.addresses.create!(
            street_and_number: row['street_and_number_primary'],
            addition: row['addition_primary'],
            postal_code: row['postal_code_primary'],
            city: row['city_primary'],
            country: row['country_primary'] ? row['country_primary'] : 'DE'
          )
          contact.primary_contact_address = primary_address
        end
        contact.save(validate: false)
        if row['street_and_number_secondary']
          contact.addresses.create!(
            street_and_number: row['street_and_number_secondary'],
            addition: row['addition_secondary'],
            postal_code: row['postal_code_secondary'],
            city: row['city_secondary'],
            country: row['country_secondary'] ? row['country_secondary'] : 'DE'
          )
        end
        if row['street_and_number_tertiary']
          contact.addresses.create!(
            street_and_number: row['street_and_number_tertiary'],
            addition: row['addition_tertiary'],
            postal_code: row['postal_code_tertiary'],
            city: row['city_tertiary'],
            country: row['country_tertiary'] ? row['country_tertiary'] : 'DE'
          )
        end
        %w[email fax phone website].each do |channel|
          if row["#{channel}_private"]
            "ContactDetail::#{channel.titleize}".constantize.new(
              contact: contact, value: row["#{channel}_private"], category: :home, primary: true
            ).save(validate: false)
          end
          if row["#{channel}_work"]
            "ContactDetail::#{channel.titleize}".constantize.new(
              contact: contact, value: row["#{channel}_work"], category: :work, primary: !row["#{channel}_private"]
            ).save(validate: false)
          end
          next unless row["#{channel}_holiday"]
          "ContactDetail::#{channel.titleize}".constantize.new(
            contact: contact, value: row["#{channel}_holiday"], category: :vacation,
            primary: !row["#{channel}_private"] && !row["#{channel}_work"]
          ).save(validate: false)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
