# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import contacts (person)'
  task :import_contacts_person, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    genders = Contact::Person.gender.values.map { |v| [v.text, v] }.to_h
    nobility_titles = Contact::Person.nobility_title.values.map { |v| [v.text, v] }.to_h
    professional_titles = Contact::Person.professional_title.values.map { |v| [v.text, v] }.to_h

    wphg_classifications = ComplianceDetail.wphg_classification.values.map { |v| [v.text, v] }.to_h
    kagb_classifications = ComplianceDetail.kagb_classification.values.map { |v| [v.text, v] }.to_h
    occupation_roles = ComplianceDetail.occupation_role.values.map { |v| [v.text, v] }.to_h

    us_tax_forms = TaxDetail.us_tax_form.values.map { |v| [v.text, v] }.to_h
    us_fatca_statuses = TaxDetail.us_fatca_status.values.map { |v| [v.text, v] }.to_h

    address_categories = {
      'Privatadresse' => :home,
      'Geschäftsadresse' => :work,
      'Urlaubsadresse' => :vacation
    }

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts "Parsing contact #{row['id']}"
        next if Contact.find_by(import_id: row['id']).present?
        contact = Contact::Person.create!(
          import_id: row['id'],
          gender: genders[row['gender']],
          nobility_title: nobility_titles[row['nobility_title']],
          professional_title: professional_titles[row['professional_title']],
          first_name: row['first_name'],
          last_name: row['last_name'],
          maiden_name: row['maiden_name'],
          date_of_birth: row['date_of_birth'] ? Date.parse(row['date_of_birth']) : nil,
          date_of_death: row['date_of_death'] ? Date.parse(row['date_of_death']) : nil,
          nationality: row['nationality'],
          comment: row['comment']
        )
        ComplianceDetail.create!(
          contact: contact,
          wphg_classification: wphg_classifications[row['wphg_classification']] || 'none',
          kagb_classification: kagb_classifications[row['kagb_classification']] || 'none',
          politically_exposed: row['politically_exposed'] == 'Ja',
          occupation_role: occupation_roles[row['occupation_role']],
          occupation_title: row['occupation_title'],
          retirement_age: row['retirement_age']
        )
        TaxDetail.create!(
          contact: contact,
          common_reporting_standard: row['common_reporting_standard'] == 'Ja',
          de_church_tax: row['de_church_tax'] == 'Ja',
          de_health_insurance: row['de_health_insurance'] == 'Ja',
          de_retirement_insurance: row['de_retirement_insurance'] == 'Ja',
          de_tax_id: row['de_tax_id']&.gsub(/\s+/, ''),
          de_tax_number: row['de_tax_number'],
          de_unemployment_insurance: row['de_unemployment_insurance'] == 'Ja',
          us_fatca_status: us_fatca_statuses[row['us_fatca_status']],
          us_tax_form: us_tax_forms[row['us_tax_form']],
          us_tax_number: row['us_tax_number']
        )
        row['foreign_tax_ids']&.split(',')&.each do |foreign_tax_id|
          contact.tax_detail.foreign_tax_numbers.create!(
            country: foreign_tax_id[0..1],
            tax_number: foreign_tax_id[3..-1]
          )
        end
        if row['street_and_number_legal']
          legal_address = contact.addresses.create!(
            category: address_categories[row['category_legal']],
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
            category: address_categories[row['category_primary']],
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
            category: address_categories[row['category_secondary']],
            street_and_number: row['street_and_number_secondary'],
            addition: row['addition_secondary'],
            postal_code: row['postal_code_secondary'],
            city: row['city_secondary'],
            country: row['country_secondary'] ? row['country_secondary'] : 'DE'
          )
        end
        if row['street_and_number_tertiary']
          contact.addresses.create!(
            category: address_categories[row['category_tertiary']],
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
