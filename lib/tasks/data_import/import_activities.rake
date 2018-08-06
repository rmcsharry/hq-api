# frozen_string_literal: true

require 'helpers/aws_s3_encrypted_helper'

# rubocop:disable Metrics/BlockLength
namespace :data_import do
  include AwsS3EncryptedHelper

  desc 'Import activities'
  task :import_activities, %i[s3_key file_folder creator_email] => [:environment] do |_task, args|
    file = decrypted_s3_tempfile(s3_key: args[:s3_key])
    creator = User.find_by(email: args[:creator_email])
    Time.zone = 'Europe/Berlin'

    ActiveRecord::Base.transaction do
      CSV.read(file, headers: CSV.read(file).third)[4..-1].each_with_index do |row, index|
        puts "Parsing activity #{index}"

        mandate = Mandate.find_by(import_id: row['mandate_id']) if row['mandate_id']
        organization = Contact::Organization.find_by(import_id: row['organization']) if row['organization']
        person = Contact::Person.find_by(import_id: row['person_id']) if row['person_id']

        types = {
          'Anrufe' => 'Activity::Call',
          'Meeting' => 'Activity::Meeting',
          'Notiz' => 'Activity::Note',
          'E-Mail' => 'Activity::Email'
        }

        types_de = {
          'Activity::Call' => 'Anruf',
          'Activity::Meeting' => 'Meeting',
          'Activity::Note' => 'Notiz',
          'Activity::Email' => 'Email'
        }

        type = types[row['type']]

        if type != 'Activity::Email'
          title = row['title'].presence || types_de[type]
          description = row['description'].presence || title
          started_at = Time.zone.strptime(row['started_at'], '%m/%d/%y %H:%M')
        else
          email_file = decrypted_s3_tempfile(s3_key: "#{args[:file_folder]}/#{row['documents']}.eml")
          mail = Mail.read(email_file.path)
          title = mail.subject.presence || row['title']
          text_body = mail.text_part.body.decoded
          text_body = text_body.force_encoding('ISO-8859-1') if text_body.encoding.name == 'ASCII-8BIT'
          description = text_body.encode('UTF-8').presence || row['description'].presence || title
          started_at = mail.date.to_s
        end

        activity = Activity.create!(
          mandates: [mandate].compact,
          contacts: [person, organization].compact,
          type: type,
          started_at: started_at,
          ended_at: row['ended_at'] ? Time.zone.strptime(row['ended_at'], '%m/%d/%y %H:%M') : nil,
          title: title,
          creator: creator,
          description: description
        )

        next unless mail
        attach_document(activity: activity, file_name: 'mail.eml', content: email_file.open.read)
        mail.attachments.each do |attachment|
          attach_document(activity: activity, file_name: attachment.filename, content: attachment.decoded)
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

def attach_document(activity:, file_name:, content:)
  Document.create!(
    category: :client_communication,
    name: file_name,
    owner: activity,
    uploader: activity.creator
  ).file.attach(
    io: StringIO.new(content),
    filename: file_name
  )
end
