# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import mandate members'
  task :import_mandate_members, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts "Parsing mandate member between contact ID #{row['contact_id']} and mandate ID #{row['mandate_id']}"
        mandate = Mandate.find_by!(import_id: row['mandate_id'])
        contact = Contact.find_by!(import_id: row['contact_id'])
        MandateMember.create!(
          mandate: mandate,
          contact: contact,
          member_type: row['member_type']
        )
      end
    end
  end
end
