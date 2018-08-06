# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import users'
  task :import_users, %i[s3_key] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each do |row|
        puts "Parsing user #{row['email']}"
        contact = Contact.find_by!(import_id: row['contact_id'])
        user_groups = []
        row['role']&.split(',')&.each do |role|
          user_group = UserGroup.find_by!(name: role.strip)
          user_groups << user_group
        end
        User.invite!(
          email: row['email'],
          contact: contact,
          comment: row['comment'],
          user_groups: user_groups,
          ews_user_id: row['ews_user_id'],
          skip_invitation: true
        )
      end
    end
  end

  desc 'Invite imported users'
  task :invite_imported_users, :environment do |_task, _args|
    User.where(confirmed_at: nil).each(&:invite!)
  end
end
# rubocop:enable Metrics/BlockLength
