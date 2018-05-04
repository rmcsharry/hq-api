# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

CONTACTS_ENDPOINT = '/v1/contacts'

RSpec.describe CONTACTS_ENDPOINT, type: :request do
  describe 'POST /v1/contacts' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    subject { -> { post(CONTACTS_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'first-name': 'Max',
              'last-name': 'Mustermann',
              'legal-address': {
                addition: 'Gartenhaus',
                category: 'home',
                city: 'Berlin',
                country: 'DE',
                'postal-code': '12345',
                state: 'Berlin',
                'street-and-number': 'Wohnstraße 13'
              }
            }
          }
        }
      end

      it 'creates a new contact' do
        is_expected.to change(Contact, :count).by(1)
        is_expected.to change(Address, :count).by(1)
        expect(response).to have_http_status(201)
        contact = Contact.find(JSON.parse(response.body)['data']['id'])
        expect(contact.first_name).to eq 'Max'
        expect(contact.last_name).to eq 'Mustermann'
        expect(contact.legal_address.street_and_number).to eq 'Wohnstraße 13'
        expect(contact.legal_address).to eq contact.primary_contact_address
      end
    end

    context 'with legal address and primary contact address' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'first-name': 'Max',
              'last-name': 'Mustermann',
              'legal-address': {
                addition: 'Gartenhaus',
                category: 'home',
                city: 'Berlin',
                country: 'DE',
                'postal-code': '12345',
                state: 'Berlin',
                'street-and-number': 'Wohnstraße 13'
              },
              'primary-contact-address': {
                category: 'work',
                city: 'Hamburg',
                country: 'DE',
                'postal-code': '54321',
                state: 'Hamburg',
                'street-and-number': 'Arbeitsstraße 15'
              }
            }
          }
        }
      end

      it 'creates a new contact' do
        is_expected.to change(Contact, :count).by(1)
        is_expected.to change(Address, :count).by(2)
        expect(response).to have_http_status(201)
        contact = Contact.find(JSON.parse(response.body)['data']['id'])
        expect(contact.first_name).to eq 'Max'
        expect(contact.last_name).to eq 'Mustermann'
        expect(contact.legal_address.street_and_number).to eq 'Wohnstraße 13'
        expect(contact.primary_contact_address.street_and_number).to eq 'Arbeitsstraße 15'
      end
    end

    context 'with invalid address' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'first-name': 'Max',
              'last-name': 'Mustermann',
              'legal-address': {
                addition: 'Gartenhaus',
                category: 'home',
                city: 'Berlin',
                country: 'DE',
                state: 'Berlin',
                'street-and-number': 'Wohnstraße 13'
              }
            }
          }
        }
      end

      it 'creates a new contact' do
        is_expected.to change(Contact, :count).by(0)
        is_expected.to change(Address, :count).by(0)
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq 'legal-address - is invalid'
      end
    end
  end
end
