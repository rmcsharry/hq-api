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
    file.write mime_body
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
end
