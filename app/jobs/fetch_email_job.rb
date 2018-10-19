# frozen_string_literal: true

# Background job for downloading .eml versions of emails from EWS
class FetchEmailJob < ApplicationJob
  def perform(activity_id, ews_options)
    mime_body = Base64.decode64(fetch_email(ews_options))
    mail = parse_mail(mime_body)
    activity = Activity.includes(:creator).find(activity_id)

    attach_document activity, 'mail.eml', mime_body
    mail.attachments.each do |attachment|
      attach_document activity, attachment.filename, attachment.decoded
    end

    process_call!(activity, mail) if voice_call?(mail)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def fetch_email(ews_options)
    ews_url = ews_options[:url]
    client = Savon.client(
      endpoint: ews_url,
      env_namespace: 'soap',
      headers: { 'Authorization' => "Bearer #{ews_options[:token]}" },
      host: ews_url,
      log: false,
      namespace: '',
      namespace_identifier: :m,
      namespaces: {
        'xmlns:m' => 'http://schemas.microsoft.com/exchange/services/2006/messages',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:t' => 'http://schemas.microsoft.com/exchange/services/2006/types'
      },
      pretty_print_xml: true,
      soap_header: '<t:RequestServerVersion Version="Exchange2013" />'
    )

    request = {
      'm:ItemIds': {
        't:ItemId': '',
        attributes!: {
          't:ItemId': {
            Id: ews_options[:id]
          }
        }
      },
      'm:ItemShape': {
        't:BaseShape': 'IdOnly',
        't:IncludeMimeContent': true
      }
    }

    response = client.call('GetItem', message: request)
    raise 'Could not fetch email from ews' unless response.success?
    response.body[:get_item_response][:response_messages][:get_item_response_message][:items][:message][:mime_content]
  end
  # rubocop:enable Metrics/MethodLength

  def parse_mail(mime_body)
    file = Tempfile.new
    file.write mime_body.force_encoding('UTF-8')
    file.rewind
    Mail.read file.path
  ensure
    file.close
    file.unlink
  end

  def attach_document(activity, filename, content)
    Document.create!(
      category: :client_communication,
      name: filename,
      owner: activity,
      uploader: activity.creator
    ).file.attach(
      io: StringIO.new(content),
      filename: filename
    )
  end

  def voice_call?(mail)
    mail.header_fields.find do |header|
      header.name == 'Content-Class' &&
        header.value == 'voice-uc'
    end.present?
  end

  def process_call!(activity, mail)
    activity.update! type: 'Activity::Call'

    body = decoded_body mail
    parse_duration!(activity, body)
  end

  def decoded_body(mail)
    body_parts = mail.body.parts
    return mail.body.decoded unless body_parts.size.positive?
    body_parts.map do |part|
      part.body.decoded
    end.join("\n")
  end

  def parse_duration!(activity, body)
    duration = body.match(/Dauer: (.*)/).to_s
    return if duration.empty?

    hours = parse_time_unit(duration, 'stunden').hours
    minutes = parse_time_unit(duration, 'minuten').minutes
    seconds = parse_time_unit(duration, 'sekunden').seconds
    activity.update! ended_at: activity.started_at + hours + minutes + seconds
  end

  def parse_time_unit(source, unit_name)
    source.match(/\d*(?= #{unit_name})/i).to_s.to_i
  end
end
