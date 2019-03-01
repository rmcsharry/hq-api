# frozen_string_literal: true

# Defines the Newsletter Subscriber mailer
class NewsletterSubscriberMailer < ApplicationMailer
  # rubocop:disable Metrics/MethodLength
  def confirmation_instructions
    subscriber = params[:record].decorate
    confirm_email_url = "#{subscriber.confirmation_base_url}?confirmation_token=#{params[:confirmation_token]}"

    mail(
      from: sender(record: subscriber),
      to: subscriber.email,
      delivery_method_options: {
        version: 'v3.1',
        'TemplateID' => template(record: subscriber).to_i,
        'TemplateLanguage' => true,
        'TemplateErrorReporting' => {
          'Email' => 'admin@shr.ps',
          'Name' => 'Sherpas Admin'
        },
        'Variables' => {
          formal_salutation: subscriber.formal_salutation,
          confirmation_url: confirm_email_url
        }
      },
      subject: subject(record: subscriber),
      body: ''
    )
  end
  # rubocop:enable Metrics/MethodLength

  private

  def sender(record:)
    if record.subscriber_context == 'hqt'
      ENV['NEWSLETTER_SUBSCRIBER_HQT_SENDER']
    else
      ENV['NEWSLETTER_SUBSCRIBER_HQAM_SENDER']
    end
  end

  def subject(record:)
    if record.subscriber_context == 'hqt'
      ENV['NEWSLETTER_SUBSCRIBER_HQT_SUBJECT']
    else
      ENV['NEWSLETTER_SUBSCRIBER_HQAM_SUBJECT']
    end
  end

  def template(record:)
    if record.subscriber_context == 'hqt'
      ENV['NEWSLETTER_SUBSCRIBER_HQT_TEMPLATE_ID']
    else
      ENV['NEWSLETTER_SUBSCRIBER_HQAM_TEMPLATE_ID']
    end
  end
end
