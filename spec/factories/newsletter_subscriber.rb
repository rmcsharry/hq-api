# frozen_string_literal: true

FactoryBot.define do
  factory :newsletter_subscriber, class: NewsletterSubscriber do
    email                     { 'admin@hqfinanz.de' }
    mailjet_list_id           { '1234' }
    confirmation_base_url     { 'https://www.hqtrust.de/confirm-newsletter-subscription' }
    confirmation_success_url  { 'https://www.hqtrust.de/confirmation-success' }

    trait :with_full_details do
      first_name          { 'Thomas' }
      last_name           { 'Guntersen' }
      gender              { :male }
      professional_title  { :prof_dr }
      nobility_title      { :baron }
    end
  end
end
