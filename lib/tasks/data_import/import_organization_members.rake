# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import organization members'
  task :import_organization_members, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    import_count = 0

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts(
          "Parsing mandate member between organization ID #{row['organization_id']} and contact ID #{row['contact_id']}"
        )
        organization = Contact::Organization.find_by(import_id: row['organization_id'])
        contact = Contact.find_by!(import_id: row['contact_id'])
        role = person_relationship_roles[row['role']]
        not_imported_roles << row['role'] if organization.present? && contact.present? && role.nil?
        next if organization.nil? || contact.nil? || role.nil?
        next if OrganizationMember.where(
          organization: organization, contact: contact, role: role
        ).count.positive?

        OrganizationMember.create!(
          organization: organization,
          contact: contact,
          role: role
        )
        import_count += 1
      end
    end

    puts "Imported #{import_count} organization members of #{CSV.read(file)[4..-1].count} rows."
    puts "Not imported roles: #{not_imported_roles.uniq.join(', ')}."
  end
end
# rubocop:enable Metrics/BlockLength

# rubocop:disable Metrics/MethodLength
def organization_member_roles
  {
    'Arbeitgeber' => :employee,
    'Assistent(in)' => :assistant,
    'Berater (Bank)' => :consultant_bank,
    'Beteiligungsgesellschaft' => :shareholder,
    'Buchhalter extern' => :bookkeeper,
    'Director' => :director,
    'Geschäftsführer' => :managing_director,
    'Gesellschaft (Beirat)' => :advisor,
    'Gesellschaft (GF)' => :managing_director,
    'Gesellschaft' => :shareholder,
    'Gesellschafter' => :shareholder,
    'HQT-FO-Mandant' => :hqt_contact,
    'HQT-Kontakt' => :hqt_contact,
    'HQT-Mitarbeiter' => :hqt_contact,
    'HQT-Prospect' => :hqt_contact,
    'Immobilienverwaltung' => :custodian_real_estate,
    'Kontakt' => :contact,
    'Kunde (Bank)' => :client_bank,
    'Kunde (Beteiligungen)' => :client_holding_company,
    'Kunde (Immobilienverwaltung)' => :custodian_real_estate,
    'Kunde (Makler)' => :broker_real_estate, # orga is the client, person is the broker
    'Kunde (Vermögensverwaltung)' => :client_wealth_management,
    'Kunde (Versicherung)' => :client_insurance,
    'Makler (Immobilien)' => :broker_real_estate, # orga is the client, person is the broker
    'Makler (Versicherung)' => :broker_insurance,
    'Mandant (M&A-Berater)' => :mandate_mergers_acquisitions_advisor,
    'Mandant (Notar)' => :mandate_notary,
    'Mandant (Rechtsanwalt)' => :mandate_lawyer,
    'Mandant (Steuerberater)' => :mandate_tax_advisor,
    'Mandant (Wirtschaftsprüfung)' => :mandate_financial_auditor,
    'Mandat' => :mandate_bookkeeper,
    'Mitarbeiter' => :employee,
    'Steuerberater' => :mandate_tax_advisor,
    'Stiftung' => :benefactor,
    'Vermieter' => :renter,
    'Vermögensverwalter' => :client_wealth_management,
    'Vorgesetzter' => :supervisor,
    'Vorstand' => :chairman,
    'wirtschaftlicher Eigentümer' => :beneficial_owner
  }
end
# rubocop:enable Metrics/MethodLength
