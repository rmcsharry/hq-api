# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import mandates'
  task :import_mandates, %i[s3_key mandate_group_id] => [:environment] do |_task, args|
    mandate_group_id = args[:mandate_group_id]

    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    categories = Mandate.category.values.map { |v| [v.text, v] }.to_h
    aasm_states = {
      'Prospect – Not Qualified' => :prospect_not_qualified,
      'Kunde' => :client,
      'Gekündigt' => :cancelled
    }
    mandate_group = MandateGroup.find(mandate_group_id)

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts "Parsing mandate #{row['id']}"
        Mandate.create!(
          import_id: row['id'],
          category: categories[row['category']],
          aasm_state: aasm_states[row['aasm_state']],
          valid_from: row['valid_from'] ? Date.strptime(row['valid_from'], '%m/%d/%Y') : nil,
          valid_to: row['valid_to'] ? Date.strptime(row['valid_to'], '%m/%d/%Y') : nil,
          datev_creditor_id: row['datev_creditor_id'],
          datev_debitor_id: row['datev_debitor_id'],
          mandate_number: row['mandate_number'],
          psplus_id: row['psplus_id'],
          primary_consultant: find_contact_by_email(email: row['primary_consultant_email']),
          secondary_consultant: find_contact_by_email(email: row['secondary_consultant_email']),
          assistant: find_contact_by_email(email: row['assistant_email']),
          bookkeeper: find_contact_by_email(email: row['bookkeeper_email']),
          mandate_groups_organizations: [mandate_group],
          comment: row['comment']
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

def find_contact_by_email(email:)
  contact = Contact.joins(:primary_email).where(contact_details: { value: email }).first
  raise "Contact not found with primary email: #{email}" if contact.blank? && email.present?

  contact
end
