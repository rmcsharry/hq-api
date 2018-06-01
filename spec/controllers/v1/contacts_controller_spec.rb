# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

CONTACTS_ENDPOINT = '/v1/contacts'

RSpec.describe CONTACTS_ENDPOINT, type: :request do
  let!(:user) { create(:user) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/contacts' do
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
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'legal-address - ist nicht gültig'
        )
      end
    end
  end

  describe 'GET /v1/contacts' do
    let!(:contacts) { create_list(:contact_person, 10, :with_contact_details) }

    context 'authenticated as user' do
      it 'fetches the contacts' do
        get(CONTACTS_ENDPOINT, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta'
        expect(body['meta']['total-record-count']).to eq 11
      end
    end

    context 'with includes' do
      let(:params) { { include: 'legal-address,primary-contact-address,primary-email,primary-phone' } }

      it 'fetches the contacts with includes' do
        get(CONTACTS_ENDPOINT, params: params, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'included', 'links'
        expect(body['included'].length).to eq 40
        expect(body['included'].count { |resource| resource['type'] == 'addresses' }).to eq 20
        expect(body['included'].count { |resource| resource['type'] == 'contact-details' }).to eq 20
        expect(body['meta']['total-record-count']).to eq 11
      end
    end
  end

  describe 'DELETE /v1/contacts/<contact_id>/relationships/contact-members' do
    subject do
      lambda do
        delete(
          "#{CONTACTS_ENDPOINT}/#{organization.id}/relationships/contact-members",
          params: payload.to_json,
          headers: auth_headers
        )
      end
    end

    let(:organization) { organization_member.organization }
    let(:payload) do
      {
        data: [
          {
            type: 'organization-members',
            id: organization_member.id
          }
        ]
      }
    end

    context 'with valid organization member' do
      let!(:organization_member) { create(:organization_member) }

      it 'deletes an organization member' do
        is_expected.to change(OrganizationMember, :count).by(-1)
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /v1/contacts/<contact_id>/relationships/organization-members' do
    subject do
      lambda do
        delete(
          "#{CONTACTS_ENDPOINT}/#{contact.id}/relationships/organization-members",
          params: payload.to_json,
          headers: auth_headers
        )
      end
    end

    let(:contact) { organization_member.contact }
    let(:payload) do
      {
        data: [
          {
            type: 'organization-members',
            id: organization_member.id
          }
        ]
      }
    end

    context 'with valid organization member' do
      let!(:organization_member) { create(:organization_member) }

      it 'deletes an organization member' do
        is_expected.to change(OrganizationMember, :count).by(-1)
        expect(response).to have_http_status(204)
      end
    end
  end
end
