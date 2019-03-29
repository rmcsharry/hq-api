# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe CONTACTS_ENDPOINT, type: :request do
  let(:contact) { create(:contact_person, :with_contact_details) }
  let!(:user) { create(:user, contact: contact, roles: %i[contacts_read contacts_write]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  let(:compliance_detail_payload) do
    {
      'kagb-classification': 'private',
      'occupation-role': 'worker',
      'occupation-title': 'CMO',
      'politically-exposed': false,
      'wphg-classification': 'born_professional'
    }
  end

  let(:tax_detail_payload) do
    {
      'de-church-tax': true,
      'de-health-insurace': false,
      'de-retirement-insurace': false,
      'de-tax-id': '12345678911',
      'de-tax-number': '21/815/08150',
      'de-tax-office': 'Amtsgericht Oberursel',
      'de-unemployment-insurance': true,
      'us-fatca-status': 'participation_ffi',
      'us-tax-form': 'w_8ben',
      'us-tax-number': '123456789'
    }
  end

  describe 'POST /v1/contacts' do
    subject { -> { post(CONTACTS_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
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
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
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

    context 'with legal address and primary contact address' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
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

    context 'with legal address, compliance detail and tax detail' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
              'legal-address': {
                addition: 'Gartenhaus',
                category: 'home',
                city: 'Berlin',
                country: 'DE',
                'postal-code': '12345',
                state: 'Berlin',
                'street-and-number': 'Wohnstraße 13'
              },
              'compliance-detail': compliance_detail_payload,
              'tax-detail': tax_detail_payload
            }
          }
        }
      end

      it 'creates a new contact', bullet: false do
        is_expected.to change(Contact, :count).by(1)
        is_expected.to change(ComplianceDetail, :count).by(1)
        is_expected.to change(TaxDetail, :count).by(1)
        is_expected.to change(Address, :count).by(1)
        expect(response).to have_http_status(201)
        contact = Contact.find(JSON.parse(response.body)['data']['id'])
        expect(contact.first_name).to eq 'Max'
        expect(contact.last_name).to eq 'Mustermann'
        expect(contact.compliance_detail.wphg_classification).to eq 'born_professional'
        expect(contact.tax_detail.de_tax_number).to eq '21/815/08150'
      end
    end

    context 'with invalid address' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
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
          'legal-address.postal-code - muss ausgefüllt werden'
        )
      end
    end

    context 'with an invalid type' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'contact-type': 'Document',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male'
            }
          }
        }
      end

      it 'returns an error' do
        is_expected.to change(Document, :count).by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'Document is not a valid value for contact-type.'
        )
      end
    end

    context 'with multiple addresses and contact details', bullet: false do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
              addresses: [
                {
                  addition: 'Gartenhaus',
                  category: 'home',
                  city: 'Berlin',
                  country: 'DE',
                  'postal-code': '12345',
                  state: 'Berlin',
                  'street-and-number': 'Wohnstraße 13'
                }, {
                  category: 'work',
                  city: 'Hamburg',
                  country: 'DE',
                  'postal-code': '54321',
                  state: 'Hamburg',
                  'street-and-number': 'Arbeitsstraße 15'
                }
              ],
              'contact-details': [
                {
                  category: 'work',
                  contact_detail_type: 'ContactDetail::Phone',
                  value: '030123456789'
                }, {
                  category: 'home',
                  contact_detail_type: 'ContactDetail::Phone',
                  value: '030987654321'
                }, {
                  category: 'work',
                  contact_detail_type: 'ContactDetail::Fax',
                  value: '030987654322'
                }, {
                  category: 'work',
                  contact_detail_type: 'ContactDetail::Email',
                  value: 'test@hqfinanz.de'
                }
              ]
            }
          }
        }
      end

      it 'creates a new contact' do
        is_expected.to change(Contact, :count).by(1)
        is_expected.to change(Address, :count).by(2)
        is_expected.to change(ContactDetail, :count).by(4)
        expect(response).to have_http_status(201)
        contact = Contact.find(JSON.parse(response.body)['data']['id'])
        expect(contact.first_name).to eq 'Max'
        expect(contact.last_name).to eq 'Mustermann'
        expect(contact.addresses.count).to eq 2
        expect(contact.contact_details.count).to eq 4
      end
    end
  end

  describe 'GET /v1/contacts' do
    let!(:contacts) { create_list(:contact_person, 10, :with_contact_details) }

    context 'authenticated as user' do
      it 'fetches the contacts' do
        get(CONTACTS_ENDPOINT, params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta'
        expect(body['meta']['total-record-count']).to eq 11
        expect(response.headers['authorization']).to_not eq auth_headers['Authorization']
        expect(response.headers['authorization']).to_not be_nil
        expect(auth_headers['Authorization']).to_not be_nil
      end
    end

    context 'with includes' do
      let(:params) { { include: 'legal-address,primary-contact-address,primary-email,primary-phone' } }

      it 'fetches the contacts with includes', bullet: false do
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

    context 'with no pagination params' do
      let!(:additional_contacts) { create_list(:contact_person, 12) }

      it 'fetches all the records' do
        get(CONTACTS_ENDPOINT, params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body['data'].length).to eq 10
        expect(body['meta']['page-count']).to eq 3
      end
    end

    context 'when authenticated via ews', bullet: false do
      let!(:user) do
        user = create(:user, roles: %i[contacts_read])
        user.authenticated_via_ews = true
        user
      end

      it 'can only read names of contacts' do
        get(CONTACTS_ENDPOINT, params: {}, headers: auth_headers)

        body = JSON.parse(response.body)
        rendered_attributes = body['data'].map do |contact|
          contact['attributes'].keys
        end.flatten.uniq

        expect(rendered_attributes).to eq(%w[contact-type first-name last-name name name-list])
      end
    end
  end

  describe 'GET /v1/contacts/<contact_id>/versions' do
    let(:user2) { create(:user, first_name: 'Norman', last_name: 'Bates') }
    let(:user3) { create(:user, first_name: 'Shelley', last_name: 'Stewart') }

    context 'with changes to the contact' do
      let(:updated_first_name) { 'John Lorenz' }
      let(:updated_last_name) { 'Moser' }
      let(:updated_date_of_birth) { Date.new(1985, 12, 23) }
      let(:updated_place_of_birth) { 'Mainz' }
      let(:original_first_name) { 'Kristoffer Jonas' }
      let(:original_last_name) { 'Klauß' }
      let(:original_date_of_birth) { Date.new(1988, 6, 29) }
      let(:original_place_of_birth) { 'Berlin' }
      let!(:contact) do
        create(
          :contact_person,
          first_name: original_first_name,
          last_name: original_last_name,
          date_of_birth: original_date_of_birth,
          place_of_birth: original_place_of_birth
        )
      end

      before do
        PaperTrail.request.whodunnit = user2.id
        contact.first_name = updated_first_name
        contact.last_name = updated_last_name
        contact.save!
        PaperTrail.request.whodunnit = user3.id
        contact.date_of_birth = updated_date_of_birth
        contact.place_of_birth = updated_place_of_birth
        contact.save!
      end

      it 'fetches the contact versions' do
        get("#{CONTACTS_ENDPOINT}/#{contact.id}/versions?sort=created-at", params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        change1 = body['data'][-3]['attributes']
        expect(change1['event']).to eq 'create'
        expect(change1['item-type']).to eq 'tax-details'
        change2 = body['data'][-2]['attributes']
        expect(change2['changed-by']).to eq 'Norman Bates'
        expect(change2['created-at']).to be_present
        expect(change2['event']).to eq 'update'
        expect(change2['item-type']).to eq 'contacts'
        expect(change2['changes']['first-name']).to eq([original_first_name, updated_first_name])
        expect(change2['changes']['last-name']).to eq([original_last_name, updated_last_name])
        expect(change2['changes']['updated-at']).to be_nil
        change3 = body['data'][-1]['attributes']
        expect(change3['event']).to eq 'update'
        expect(change3['changed-by']).to eq 'Shelley Stewart'
        expect(change3['created-at']).to be_present
        expect(change3['item-type']).to eq 'contacts'
        expect(change3['changes']['date-of-birth']).to eq([original_date_of_birth.to_s, updated_date_of_birth.to_s])
        expect(change3['changes']['place-of-birth']).to eq([original_place_of_birth, updated_place_of_birth])
      end
    end

    context 'with changes to the contact addresses' do
      let!(:contact) { create(:contact_person, :with_contact_details, street_and_number: original_street_and_number) }
      let!(:original_primary_contact_address) { contact.primary_contact_address }
      let!(:original_legal_address) { contact.legal_address }
      let(:original_street_and_number) { '875 South Bundy Drive' }
      let(:updated_street_and_number) { '742 Evergreen Terrace' }

      before do
        PaperTrail.request.whodunnit = user2.id
        contact.legal_address.street_and_number = updated_street_and_number
        contact.legal_address.save!
        PaperTrail.request.whodunnit = user3.id
        contact.primary_contact_address = create(:address)
        contact.save!
        PaperTrail.request.whodunnit = user2.id
        contact.legal_address = contact.primary_contact_address
        contact.save!
      end

      it 'fetches the contact versions' do
        get(
          "#{CONTACTS_ENDPOINT}/#{contact.id}/versions",
          params: { sort: '-created-at', page: { number: 1, size: 5 } },
          headers: auth_headers
        )
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        expect(body['data'].count).to eq 5
        change1 = body['data'].third['attributes']
        expect(change1['changed-by']).to eq 'Norman Bates'
        expect(change1['created-at']).to be_present
        expect(change1['event']).to eq 'update'
        expect(change1['item-type']).to eq 'addresses'
        expect(change1['changes']['street-and-number']).to eq([original_street_and_number, updated_street_and_number])
        change2 = body['data'].second['attributes']
        expect(change2['changed-by']).to eq 'Shelley Stewart'
        expect(change2['created-at']).to be_present
        expect(change2['event']).to eq 'update'
        expect(change2['item-type']).to eq 'contacts'
        expect(change2['changes']['primary-contact-address-id']).to eq(
          [original_primary_contact_address.id, contact.primary_contact_address.id]
        )
        change3 = body['data'].first['attributes']
        expect(change3['changed-by']).to eq 'Norman Bates'
        expect(change3['created-at']).to be_present
        expect(change3['event']).to eq 'update'
        expect(change3['item-type']).to eq 'contacts'
        expect(change3['changes']['legal-address-id']).to eq(
          [original_legal_address.id, contact.primary_contact_address.id]
        )
      end
    end

    context 'with changes to the foreign tax number' do
      let!(:contact) { create(:contact_organization) }
      let(:original_tax_number) { '1234567890' }
      let(:updated_tax_number) { '0987654321' }

      before do
        PaperTrail.request.whodunnit = user2.id
        contact.save!
        foreign_tax_number = create(
          :foreign_tax_number, tax_detail: contact.tax_detail, tax_number: original_tax_number
        )
        PaperTrail.request.whodunnit = user3.id
        foreign_tax_number.tax_number = updated_tax_number
        foreign_tax_number.save!
      end

      it 'fetches the contact versions' do
        get("#{CONTACTS_ENDPOINT}/#{contact.id}/versions?sort=-created-at", params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        change1 = body['data'].first['attributes']
        expect(change1['changed-by']).to eq 'Shelley Stewart'
        expect(change1['created-at']).to be_present
        expect(change1['event']).to eq 'update'
        expect(change1['item-type']).to eq 'foreign-tax-numbers'
        expect(change1['changes']['tax-number']).to eq [original_tax_number, updated_tax_number]
        change2 = body['data'].second['attributes']
        expect(change2['changed-by']).to eq 'Norman Bates'
        expect(change2['created-at']).to be_present
        expect(change2['event']).to eq 'create'
        expect(change2['item-type']).to eq 'foreign-tax-numbers'
        expect(change2['changes']['tax-number']).to eq [nil, original_tax_number]
        change3 = body['data'].third['attributes']
        expect(change3['changed-by']).to be_nil
        expect(change3['created-at']).to be_present
        expect(change3['event']).to eq 'create'
        expect(change3['item-type']).to eq 'tax-details'
        expect(change3['changes']['contact-id']).to eq [nil, contact.id]
      end
    end

    context 'with changes to the primary phone number' do
      let!(:contact) { create(:contact_person, :with_contact_details, phone: original_phone) }
      let(:original_phone) { '+49301234567' }
      let(:updated_phone) { '+49301234568' }

      before do
        PaperTrail.request.whodunnit = user2.id
        current_primary_phone = contact.primary_phone
        current_primary_phone.value = updated_phone
        current_primary_phone.save!
        PaperTrail.request.whodunnit = user3.id
        current_primary_phone.primary = false
        current_primary_phone.save!
        create(:phone, :primary, contact: contact, value: original_phone)
      end

      it 'fetches the contact versions' do
        get("#{CONTACTS_ENDPOINT}/#{contact.id}/versions?sort=-created-at", params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        change1 = body['data'].first['attributes']
        expect(change1['changed-by']).to eq 'Shelley Stewart'
        expect(change1['created-at']).to be_present
        expect(change1['event']).to eq 'create'
        expect(change1['item-type']).to eq 'contact-details'
        expect(change1['changes']['value']).to eq [nil, original_phone]
        change2 = body['data'].second['attributes']
        expect(change2['changed-by']).to eq 'Shelley Stewart'
        expect(change2['created-at']).to be_present
        expect(change2['event']).to eq 'update'
        expect(change2['item-type']).to eq 'contact-details'
        expect(change2['changes']['primary']).to eq [true, false]
        change3 = body['data'].third['attributes']
        expect(change3['changed-by']).to eq 'Norman Bates'
        expect(change3['created-at']).to be_present
        expect(change3['event']).to eq 'update'
        expect(change3['item-type']).to eq 'contact-details'
        expect(change3['changes']['value']).to eq [original_phone, updated_phone]
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

  describe 'PATCH /v1/contacts' do
    subject { -> { patch("#{CONTACTS_ENDPOINT}/#{contact.id}", params: payload.to_json, headers: auth_headers) } }
    let(:contact) { create(:contact_person) }

    context 'with compliance detail and tax detail' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            id: contact.id,
            attributes: {
              'first-name': 'Max',
              'last-name': 'Mustermann',
              'compliance-detail': compliance_detail_payload,
              'tax-detail': tax_detail_payload
            }
          }
        }
      end

      it 'updates the contact' do
        subject.call
        expect(response).to have_http_status(200)
        contact.reload
        expect(contact.first_name).to eq 'Max'
        expect(contact.last_name).to eq 'Mustermann'
        expect(contact.compliance_detail.wphg_classification).to eq 'born_professional'
        expect(contact.tax_detail.de_tax_number).to eq '21/815/08150'
      end
    end

    context 'with multiple addresses' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            id: contact.id,
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
              addresses: [
                {
                  addition: 'Gartenhaus',
                  category: 'home',
                  city: 'Berlin',
                  country: 'DE',
                  'postal-code': '12345',
                  state: 'Berlin',
                  'street-and-number': 'Wohnstraße 13'
                }, {
                  category: 'work',
                  city: 'Hamburg',
                  country: 'DE',
                  'postal-code': '54321',
                  state: 'Hamburg',
                  'street-and-number': 'Arbeitsstraße 15'
                }
              ]
            }
          }
        }
      end

      it 'is not allowed' do
        subject.call
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq('addresses is not allowed.')
        is_expected.to change(Address, :count).by(0)
      end
    end

    context 'with multiple contact details' do
      let(:payload) do
        {
          data: {
            type: 'contacts',
            id: contact.id,
            attributes: {
              'contact-type': 'Contact::Person',
              'first-name': 'Max',
              'last-name': 'Mustermann',
              gender: 'male',
              'contact-details': [
                {
                  category: 'work',
                  contact_detail_type: 'ContactDetail::Phone',
                  value: '030123456789'
                }, {
                  category: 'home',
                  contact_detail_type: 'ContactDetail::Phone',
                  value: '030987654321'
                }, {
                  category: 'work',
                  contact_detail_type: 'ContactDetail::Fax',
                  value: '030987654322'
                }, {
                  category: 'work',
                  contact_detail_type: 'ContactDetail::Email',
                  value: 'test@hqfinanz.de'
                }
              ]
            }
          }
        }
      end

      it 'is not allowed' do
        subject.call
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq('contact-details is not allowed.')
        is_expected.to change(ContactDetail, :count).by(0)
      end
    end
  end
end
