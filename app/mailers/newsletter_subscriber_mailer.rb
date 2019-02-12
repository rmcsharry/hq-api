# frozen_string_literal: true

# Defines the Newsletter Subscriber mailer
class NewsletterSubscriberMailer < ApplicationMailer
  # rubocop:disable Metrics/MethodLength
  def confirmation_instructions
    subscriber = params[:record].decorate
    confirm_email_url = "#{subscriber.confirmation_base_url}?confirmation_token=#{params[:confirmation_token]}"
    mail(
      from: 'HQ Trust Service <service@hqtrust.de>',
      to: subscriber.email,
      delivery_method_options: {
        version: 'v3.1',
        'TemplateID' => 682_266,
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
      subject: 'HQ Trust: Bestätigen Sie Ihre E-Mail-Adresse',
      body: ''
    )
  end
  # rubocop:enable Metrics/MethodLength
end
