# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import bank accounts'
  task :import_bank_accounts, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts "Parsing bank account with mandate ID #{row['mandate_id']}"
        mandate = Mandate.find_by!(import_id: row['mandate_id'])
        bank = Contact::Organization.find_by(import_id: row['bank_id']) if row['bank_id']
        BankAccount.new(
          mandate: mandate,
          bank: bank,
          account_type: row['account_type'],
          owner: row['owner'],
          iban: row['iban'],
          bic: row['bic'],
          bank_account_number: row['bank_account_number'],
          bank_routing_number: row['bank_routing_number'],
          currency: row['currency'] || 'EUR'
        ).save(validate: false)
      end
    end
  end
end
