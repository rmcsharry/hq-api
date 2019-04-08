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
        next if InterPersonRelationship.where(
          source_person: source_person, target_person: target_person, role: role
        ).count.positive?

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
    'Arbeitgeber' => :employer,
    'Architekt' => :architect,
    'Assistent(in)' => :assistant,
    'Berater (Bank)' => :bank_advisor,
    'Berater (Immobilien)' => :estate_agent,
    'Berater (Private Equity)' => :private_equity_consultant,
    'Bruder / Schwester' => :brother_sister,
    'Buchhalter HQA' => :bookkeeper,
    'Darlehensgeber' => :loaner,
    'Darlehensnehmer' => :debtor,
    'Enkel' => :granddaughter_grandson,
    'Geschwister' => :brother_sister,
    'Großeltern' => :grandma_grandpa,
    'HQT-Akquisiteur' => :hqt_contact,
    'HQT-Berater' => :hqt_contact,
    'HQT-Kontakt' => :hqt_contact,
    'HQT-Mitarbeiter' => :hqt_contact,
    'Immobilienverwaltung' => :real_estate_manager,
    'Kontakt' => :acquaintance,
    'Kunde (Bank)' => :bank_advisor_client,
    'Kunde (Immobilienberatung)' => :estate_agent_mandate,
    'Kunde (Immobilienverwaltung)' => :real_estate_manager_client,
    'Kunde (Makler)' => :real_estate_broker_client,
    'Kunde (Private Equity)' => :private_equity_consultant_mandate,
    'Kunde (Vermögensverwaltung)' => :wealth_manager_client,
    'Kunde (Versicherung)' => :insurance_broker_client,
    'M&A-Berater' => :mergers_acquisitions_advisor,
    'Makler (Immobilien)' => :estate_agent,
    'Makler (Versicherung)' => :insurance_broker,
    'Mandant (M&A-Berater)' => :mergers_acquisitions_advisor_mandate,
    'Mandant (Notar)' => :notary_mandate,
    'Mandant (Rechtsanwalt)' => :lawyer_mandate,
    'Mandant (Steuerberater)' => :tax_mandate,
    'Mandant (Wirtschaftsprüfung)' => :financial_auditor_mandate,
    'Mandant' => :bookkeeper_mandate,
    'Mieter' => :renter,
    'Mitarbeiter' => :employee,
    'Mutter' => :father_mother,
    'Neffe/Nichte' => :nephew_niece,
    'Nichte / Neffe' => :nephew_niece,
    'Notar' => :notary,
    'Onkel/Tante' => :aunt_uncle,
    'Partner' => :husband_wife,
    'Rechtsanwalt' => :lawyer,
    'Schwester / Bruder' => :brother_sister,
    'Sohn / Tochter' => :daughter_son,
    'Steuerberater' => :tax_advisor,
    'Tante' => :aunt_uncle,
    'Tochter / Sohn' => :daughter_son,
    'Vater' => :father_mother,
    'Vermieter' => :landlord,
    'Vermögensverwalter' => :wealth_manager,
    'Verwalter (Immobilienverwaltung)' => :real_estate_manager,
    'Vorgesetzter' => :boss,
    'Wirtschaftsprüfer' => :financial_auditor
  }
end
# rubocop:enable Metrics/MethodLength
