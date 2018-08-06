# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

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
        next unless organization
        contact = Contact.find_by!(import_id: row['contact_id'])
        OrganizationMember.create!(
          organization: organization,
          contact: contact,
          role: row['role']
        )
        import_count += 1
      end
    end

    puts "Imported #{import_count} organization members of #{CSV.read(file)[4..-1].count} rows."
  end
end
