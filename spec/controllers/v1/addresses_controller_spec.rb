# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

ADDRESSES_ENDPOINT = '/v1/addresses'

RSpec.describe ADDRESSES_ENDPOINT, type: :request do
  let!(:user) { create(:user) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/addresses' do
    let!(:contact) { create(:contact_person, :with_contact_details) }
    subject { -> { post(ADDRESSES_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'addresses',
            attributes: {
              addition: 'Gartenhaus',
              category: 'home',
              city: 'Berlin',
              country: 'DE',
              'postal-code': '12345',
              state: 'Berlin',
              'street-and-number': 'Wohnstraße 13',
              'primary-contact-address': false,
              'legal-address': true
            },
            relationships: {
              contact: {
                data: { id: contact.id, type: 'contacts' }
              }
            }
          }
        }
      end

      it 'updates the address' do
        is_expected.to change(Address, :count).by(1)
        expect(response).to have_http_status(201)
        address = Address.find(JSON.parse(response.body)['data']['id'])
        expect(address.street_and_number).to eq 'Wohnstraße 13'
        expect(address.city).to eq 'Berlin'
        expect(address.contact.legal_address).to eq address
        expect(address.contact.primary_contact_address).to_not eq address
      end
    end
  end

  describe 'PATCH /v1/addresses' do
    let!(:address) { create(:address) }
    subject { -> { patch("#{ADDRESSES_ENDPOINT}/#{address.id}", params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'addresses',
            id: address.id,
            attributes: {
              addition: 'Gartenhaus',
              category: 'home',
              city: 'Berlin',
              country: 'DE',
              'postal-code': '12345',
              state: 'Berlin',
              'street-and-number': 'Wohnstraße 13',
              'primary-contact-address': true,
              'legal-address': true
            }
          }
        }
      end

      it 'updates the address' do
        is_expected.to change(Address, :count).by(0)
        expect(response).to have_http_status(200)
        address.reload
        expect(address.street_and_number).to eq 'Wohnstraße 13'
        expect(address.city).to eq 'Berlin'
        expect(address.contact.legal_address).to eq address
        expect(address.contact.primary_contact_address).to eq address
      end
    end
  end

  describe 'DELETE /v1/addresses' do
    subject { -> { delete("#{ADDRESSES_ENDPOINT}/#{address.id}", params: {}, headers: auth_headers) } }

    context 'with valid payload' do
      let!(:address) { create(:address) }

      it 'deletes the address' do
        is_expected.to change(Address, :count).by(-1)
        expect(response).to have_http_status(204)
      end
    end

    context 'for current legal address' do
      let(:address) { contact.legal_address }
      let!(:contact) { create(:contact_person, :with_contact_details) }

      it 'does not delete the address' do
        is_expected.to change(Address, :count).by(0)
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'Cannot delete address while it is the legal address.'
        )
      end
    end

    context 'for current primary contact address' do
      let(:address) { contact.primary_contact_address }
      let!(:contact) { create(:contact_person, :with_contact_details) }

      it 'does not delete the address' do
        is_expected.to change(Address, :count).by(0)
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'Cannot delete address while it is the primary contact address.'
        )
      end
    end
  end
end
