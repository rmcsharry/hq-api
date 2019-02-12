# frozen_string_literal: true

# Background job syncing Newsletter Subscribers to Mailjet
class SyncNewsletterSubscriberJob < ApplicationJob
  def perform(newsletter_subscriber_id)
    subscriber = NewsletterSubscriber.find(newsletter_subscriber_id).decorate

    raise 'Newsletter Subscriber is not confirmed yet' unless subscriber.confirmed?

    sync_to_mailjet(subscriber: subscriber)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def sync_to_mailjet(subscriber:)
    Mailjet::Contactslist_managemanycontacts.create(
      id: subscriber.mailjet_list_id,
      action: 'addforce',
      contacts: [
        {
          'Email' => subscriber.email,
          'Name' => subscriber.name,
          'Properties' => {
            'first_name' => subscriber.first_name,
            'formal_salutation' => subscriber.formal_salutation,
            'gender' => subscriber.gender,
            'last_name' => subscriber.last_name,
            'nobility_title' => subscriber.nobility_title,
            'professional_title' => subscriber.professional_title
          }
        }
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength
end
