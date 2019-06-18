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
    properties = {
      'first_name' => subscriber.first_name,
      'formal_salutation' => subscriber.formal_salutation,
      'gender' => subscriber.gender,
      'last_name' => subscriber.last_name,
      'nobility_title' => subscriber.nobility_title,
      'professional_title' => subscriber.professional_title
    }

    # Only sync questionnair results if there are any present to not overwrite them in case the person signs up
    # for a newsletter AFTER already having submitted and confirmed a questionnaire.
    # A user might fill out the questionnaire one day and at some later time subscribe to the newsletter. In that case,
    # we want to preserve those earlier questionnaire results, not overwrite them.
    questionnaire_results = { 'questionnaire_results': questionnaire_results(subscriber: subscriber).to_s }
    properties.merge(questionnaire_results) if subscriber.questionnaire_results

    Mailjet::Contactslist_managemanycontacts.create(
      id: subscriber.mailjet_list_id,
      action: 'addforce',
      contacts: [
        {
          'Email' => subscriber.email,
          'Name' => subscriber.name,
          'Properties' => properties
        }
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength

  def questionnaire_results(subscriber:)
    return '' unless subscriber.questionnaire_results

    answers = subscriber.questionnaire_results['answers']
    total_points = answers.sum { |a| a['question-value'] }
    scored_points = answers.sum { |a| a['selected-btn-value'] }
    result = "#{scored_points} von #{total_points} Punkten ––– "
    result + answers.map do |answer|
      "#{answer['question-text']}: #{answer['selected-btn-text']}"
    end.join(' // ')
  end
end
