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

        organization = Contact::Organization.find_by(import_id: row['organization_id']) if row['organization_id']
        person = Contact::Person.find_by(import_id: row['person_id']) if row['person_id']

        mandates = if organization.present?
                     organization.mandates
                   else
                     person.mandates
                   end

        creator = mandates.first&.primary_consultant&.user.presence || creator if mandates.present?
        creator = User.find_by(email: row['email_creator']) || creator if row['email_creator'].present?
        contacts = mandates.present? ? [] : [person, organization].compact

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
          started_at = Time.zone.strptime(row['started_at'], '%m/%d/%Y %H:%M')
        else
          email_file = decrypted_s3_tempfile(s3_key: "#{args[:file_folder]}/#{row['documents']}.eml")
          mail = Mail.read(email_file.path)
          title = mail.subject.presence || row['title']
          description = text_body(mail: mail).presence || row['description'].presence || title
          started_at = mail.date.to_s
        end

        # rubocop:disable Performance/StringReplacement
        # rubocop:disable Style/StringLiterals
        description = description.gsub("\r\n", "\n").gsub("\n", '\\n').gsub("\"", '\\\"').gsub("\t", " ")
        description = "{\"ops\":[{\"insert\":\"#{description}\"}]}"
        # rubocop:enable Performance/StringReplacement
        # rubocop:enable Style/StringLiterals

        activity = Activity.create!(
          mandates: mandates.to_a,
          contacts: contacts,
          type: type,
          started_at: started_at,
          ended_at: row['ended_at'] ? Time.zone.strptime(row['ended_at'], '%m/%d/%Y %H:%M') : nil,
          title: title,
          creator: creator,
          description: description
        )

        next unless mail
        attach_document(activity: activity, file_name: 'mail.eml', content: email_file.open.read)
        mail.attachments.each do |attachment|
          attach_document(activity: activity, file_name: attachment.filename, content: attachment.decoded)
        end
        mail = nil # rubocop:disable Lint/UselessAssignment
        email_file.close
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

# rubocop:disable Metrics/AbcSize
def text_body(mail:)
  if mail.multipart?
    text_body = text_body(mail: mail.body.parts.first)
  elsif mail.text_part&.body.present?
    text_body = mail.text_part.body.decoded
    text_body = text_body.force_encoding('ISO-8859-1') if text_body.encoding.name == 'ASCII-8BIT'
  else
    text_body = parse_html_body(mail_part: mail)
  end
  text_body.encode('UTF-8')
end

def parse_html_body(mail_part:)
  text_body = if mail_part.charset == 'iso-8859-1'
                mail_part.body.decoded.force_encoding('ISO-8859-1').encode('UTF-8')
              elsif mail_part.charset == 'windows-1252'
                mail_part.body.decoded.force_encoding('windows-1252').encode('UTF-8')
              else
                mail_part.body.decoded.force_encoding('ISO-8859-1').force_encoding('UTF-8')
              end
  Nokogiri::HTML(Nokogiri::HTML(Nokogiri::HTML(text_body).inner_html).text).text
end
# rubocop:enable Metrics/AbcSize
