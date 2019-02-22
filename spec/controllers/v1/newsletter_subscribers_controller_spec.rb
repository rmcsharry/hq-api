# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe NEWSLETTER_SUBSCRIBERS_ENDPOINT, type: :request do
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  ENV['WHITELISTED_URLS'] = 'https://www.hqtrust.de'

  describe 'POST /v1/newsletter-subscribers' do
    subject { -> { post(NEWSLETTER_SUBSCRIBERS_ENDPOINT, params: payload.to_json, headers: headers) } }

    let(:email) { 'max.mustermann@hqfinanz.de' }
    let(:confirmation_base_url) { 'https://www.hqtrust.de/confirm-newsletter-subscription' }
    let(:confirmation_success_url) { 'https://www.hqtrust.de/confirmation-success' }
    let(:payload) do
      {
        data: {
          type: 'newsletter_subscribers',
          attributes: {
            email: email,
            'mailjet-list-id': '1234',
            'confirmation-base-url': confirmation_base_url,
            'confirmation-success-url': confirmation_success_url
          }
        }
      }
    end

    context 'with minimal valid payload' do
      it 'creates a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(1)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(response).to have_http_status(201)
        expect(ActionMailer::Base.deliveries.last.header['From'].value).to eq 'HQ Trust Service <service@hqtrust.de>'
        expect(ActionMailer::Base.deliveries.last.header['Subject'].value).to eq(
          'HQ Trust: Bestätigen Sie Ihre E-Mail-Adresse'
        )
        subscriber = NewsletterSubscriber.find(JSON.parse(response.body)['data']['id'])
        expect(subscriber.email).to eq email
        expect(subscriber.mailjet_list_id).to eq '1234'
        expect(subscriber.confirmation_base_url).to eq 'https://www.hqtrust.de/confirm-newsletter-subscription'
        expect(subscriber.confirmation_success_url).to eq 'https://www.hqtrust.de/confirmation-success'
        json_body = JSON.parse(response.body)
        expect(json_body['meta']).to be_nil
      end
    end

    context 'with hqam as context' do
      let(:payload) do
        {
          data: {
            type: 'newsletter_subscribers',
            attributes: {
              email: email,
              'mailjet-list-id': '1234',
              'confirmation-base-url': confirmation_base_url,
              'confirmation-success-url': confirmation_success_url,
              'subscriber-context': 'hqam'
            }
          }
        }
      end

      it 'creates a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(1)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(response).to have_http_status(201)
        expect(ActionMailer::Base.deliveries.last.header['From'].value).to eq(
          'HQ Asset Management Service <service@hqam.com>'
        )
        expect(ActionMailer::Base.deliveries.last.header['Subject'].value).to eq(
          'HQ Asset Management: Bestätigen Sie Ihre E-Mail-Adresse'
        )
        subscriber = NewsletterSubscriber.find(JSON.parse(response.body)['data']['id'])
        expect(subscriber.email).to eq email
        expect(subscriber.subscriber_context).to eq 'hqam'
        json_body = JSON.parse(response.body)
        expect(json_body['meta']).to be_nil
      end
    end

    context 'with full valid payload' do
      let(:payload) do
        {
          data: {
            type: 'newsletter_subscribers',
            attributes: {
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
              'nobility-title': 'baron',
              'professional-title': 'prof_dr',
              email: email,
              'mailjet-list-id': '1234',
              'confirmation-base-url': 'https://www.hqtrust.de/confirm-newsletter-subscription',
              'confirmation-success-url': 'https://www.hqtrust.de/confirmation-success'
            }
          }
        }
      end

      it 'creates a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(1)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(response).to have_http_status(201)
        expect(ActionMailer::Base.deliveries.last.header['From'].value).to eq 'HQ Trust Service <service@hqtrust.de>'
        subscriber = NewsletterSubscriber.find(JSON.parse(response.body)['data']['id'])
        expect(subscriber.first_name).to eq 'Max'
        expect(subscriber.last_name).to eq 'Mustermann'
        expect(subscriber.email).to eq email
        expect(subscriber.nobility_title).to eq 'baron'
        expect(subscriber.professional_title).to eq 'prof_dr'
        expect(subscriber.mailjet_list_id).to eq '1234'
        expect(subscriber.confirmation_base_url).to eq 'https://www.hqtrust.de/confirm-newsletter-subscription'
        expect(subscriber.confirmation_success_url).to eq 'https://www.hqtrust.de/confirmation-success'
        json_body = JSON.parse(response.body)
        expect(json_body['meta']).to be_nil
      end
    end

    context 'with incomplete payload' do
      let(:payload) do
        {
          data: {
            type: 'newsletter_subscribers',
            attributes: {
              'first-name': 'Max',
              'last-name': 'Mustermann'
            }
          }
        }
      end

      it 'does not create a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(0)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(0)
        expect(response).to have_http_status(422)
      end
    end

    context 'without confirmation base url' do
      let(:confirmation_base_url) { nil }

      it 'does not create a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(0)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'The required parameter, confirmation_base_url, is missing.'
        )
      end
    end

    context 'with evil confirmation base url' do
      let(:confirmation_base_url) { 'http://evil-domain.com/confirm' }

      it 'does not create a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(0)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'http://evil-domain.com/confirm is not a valid value for confirmation_base_url.'
        )
      end
    end

    context 'without confirmation success url' do
      let(:confirmation_success_url) { nil }

      it 'does not create a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(0)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'The required parameter, confirmation_success_url, is missing.'
        )
      end
    end

    context 'and evil confirmation success url' do
      let(:confirmation_success_url) { 'http://evil-domain.com/confirmation-success' }

      it 'does not create a new newsletter subscriber' do
        is_expected.to change(NewsletterSubscriber, :count).by(0)
        is_expected.to change { ActionMailer::Base.deliveries.size }.by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'http://evil-domain.com/confirmation-success is not a valid value for confirmation_success_url.'
        )
      end
    end
  end

  describe 'GET /v1/newsletter-subscribers/confirm-subscription' do
    subject { -> { get(url, params: {}, headers: headers) } }

    before(:all) do
      @queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
    end

    after(:all) do
      ActiveJob::Base.queue_adapter = @queue_adapter
    end

    let(:url) do
      "#{NEWSLETTER_SUBSCRIBERS_ENDPOINT}/confirm-subscription?confirmation_token=#{confirmation_token}"
    end
    let(:confirmation_success_url) { 'https://www.hqtrust.de/confirmation-success' }
    let(:subscriber) { create(:newsletter_subscriber) }

    context 'with valid token' do
      let(:confirmation_token) { subscriber.instance_variable_get(:@raw_confirmation_token) }

      it 'it redirects to confirmation success url and confirms the subscriber' do
        subject.call
        expect(subscriber.reload.state).to eq 'confirmed'
        expect(subscriber.confirmation_token).to be_nil
        expect(subscriber.confirmed_at).to be_present
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(confirmation_success_url)
      end
    end

    context 'with invalid token' do
      let(:confirmation_token) { 'asdf' }

      it 'it redirects to confirmation failure url and does not change any subscriber' do
        subject.call
        expect(subscriber.reload.state).to eq 'confirmation_sent'
        expect(subscriber.confirmation_token).to be_present
        expect(subscriber.confirmed_at).to be_nil
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(ENV['NEWSLETTER_SUBSCRIBER_CONFIRMATION_FAILURE_URL'])
      end
    end
  end
end
