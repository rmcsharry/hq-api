# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import person relationships'
  task :import_person_relationships, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    import_count = 0
    not_imported_roles = []

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts(
          "Parsing relationships between contact ID #{row['organization_id']} and contact ID #{row['contact_id']}"
        )
        source_person = Contact::Person.find_by(import_id: row['organization_id'])
        target_person = Contact::Person.find_by(import_id: row['contact_id'])
        role = person_relationship_roles[row['role']]
        not_imported_roles << row['role'] if source_person.present? && target_person.present? && role.nil?
        next if source_person.nil? || target_person.nil? || role.nil?
        InterPersonRelationship.create!(
          source_person: source_person,
          target_person: target_person,
          role: role
        )
        import_count += 1
      end
    end

    puts "Imported #{import_count} person relationships of #{CSV.read(file)[4..-1].count} rows."
    puts "Not imported roles: #{not_imported_roles.uniq.join(', ')}."
  end
end
# rubocop:enable Metrics/BlockLength

# rubocop:disable Metrics/MethodLength
def person_relationship_roles
  {
    'Partner' => :husband_wife,
    'Bruder / Schwester' => :brother_sister,
    'Mandant (Steuerberater)' => :tax_mandate,
    'Schwester / Bruder' => :brother_sister,
    'Mandant (Rechtsanwalt)' => :lawyer_mandate,
    'Kunde (Vermögensverwaltung)' => :wealth_manager_client,
    'Mandant (Notar)' => :notary_mandate,
    'Steuerberater' => :tax_advisor,
    'Geschwister' => :brother_sister,
    'Arbeitgeber' => :employer,
    'Notar' => :notary,
    'Vermögensverwalter' => :wealth_manager,
    'Vorgesetzter' => :boss,
    'Vater' => :father_mother,
    'Mutter' => :father_mother,
    'Tochter / Sohn' => :daughter_son,
    'Mitarbeiter' => :employee,
    'Makler (Versicherung)' => :insurance_broker,
    'Verwalter (Immobilienverwaltung)' => :real_estate_manager,
    'Kunde (Immobilienverwaltung)' => :real_estate_manager_client,
    'Berater (Bank)' => :bank_advisor,
    'Kunde (Bank)' => :bank_advisor_client,
    'Berater (Immobilien)' => :estate_agent,
    'Assistent(in)' => :assistant,
    'Makler (Immobilien)' => :estate_agent,
    'Sohn / Tochter' => :daughter_son,
    'Tante' => :aunt_uncle,
    'Onkel/Tante' => :aunt_uncle,
    'Rechtsanwalt' => :lawyer,
    'Großeltern' => :grandma_grandpa,
    'Mieter' => :renter,
    'Wirtschaftsprüfer' => :financial_auditor,
    'Kunde (Versicherung)' => :insurance_broker_client,
    'Architekt' => :architect,
    'Berater (Private Equity)' => :private_equity_consultant,
    'Darlehensnehmer' => :loaner,
    'Nichte / Neffe' => :nephew_niece,
    'Mandant (M&A-Berater)' => :mergers_acquisitions_advisor_mandate,
    'M&A-Berater' => :mergers_acquisitions_advisor
  }
end
# rubocop:enable Metrics/MethodLength
