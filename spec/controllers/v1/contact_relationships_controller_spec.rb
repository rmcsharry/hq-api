# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe CONTACT_RELATIONSHIPS_ENDPOINT, type: :request do
  let(:user) { create(:user, roles: %i[contacts_read]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/contact-relationships' do
    let(:person1) { create :contact_person, first_name: 'A', last_name: 'Z' }
    let(:person2) { create :contact_person, first_name: 'B', last_name: 'Y' }
    let(:person3) { create :contact_person, first_name: 'C', last_name: 'X' }
    let(:person4) { create :contact_person, first_name: 'D', last_name: 'W' }

    let(:org1) { create :contact_organization, organization_name: 'D' }
    let(:org2) { create :contact_organization, organization_name: 'C' }
    let(:org3) { create :contact_organization, organization_name: 'B' }
    let(:org4) { create :contact_organization, organization_name: 'A' }

    context 'with realistic person to person relationships' do
      let(:source) { create :contact_person, first_name: 'Source', last_name: 'Person' }
      let(:alexa) { create :contact_person, first_name: 'Luna', last_name: 'Alexa', professional_title: :dr_dr }
      let(:lack) { create :contact_person, first_name: 'Len', last_name: 'Lack' }

      let!(:alexa_relationship) do
        create :person_person_relationship, source_contact: source, target_contact: alexa, role: :aunt_uncle
      end
      let!(:lack_relationship) do
        create :person_person_relationship, source_contact: source, target_contact: lack, role: :parent
      end

      context 'filtered by the source-contacts id' do
        it 'sorts relationships by name-list' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: {
              filter: {
                contactId: source.id,
                'source_contact.type': 'Contact::Person',
                'target_contact.type': 'Contact::Person'
              },
              sort: 'targetContact'
            },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq alexa_relationship.id
          expect(data[1]['id']).to eq lack_relationship.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end
    end

    context 'with multiple person person relationships' do
      let!(:relationship1) { create :person_person_relationship, source_contact: person1, target_contact: person2 }
      let!(:relationship2) { create :person_person_relationship, source_contact: person3, target_contact: person1 }
      let!(:relationship3) { create :person_person_relationship, source_contact: person1, target_contact: person4 }
      let!(:relationship4) { create :person_person_relationship, source_contact: person2, target_contact: person4 }

      context 'with filter by contact id' do
        it 'sorts relationships by name that is not the filtered contact' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: { filter: { contactId: person1.id }, sort: 'targetContact' },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq relationship3.id
          expect(data[1]['id']).to eq relationship2.id
          expect(data[2]['id']).to eq relationship1.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end

      context 'without filter by contact id' do
        it 'sorts relationships by target first, source second' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: { sort: 'targetContact' },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq relationship4.id
          expect(data[1]['id']).to eq relationship3.id
          expect(data[2]['id']).to eq relationship1.id
          expect(data[3]['id']).to eq relationship2.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end
    end

    context 'with multiple person organization relationships' do
      let!(:relationship1) { create :person_organization_relationship, source_contact: person1, target_contact: org1 }
      let!(:relationship2) { create :person_organization_relationship, source_contact: person1, target_contact: org2 }
      let!(:relationship3) { create :person_organization_relationship, source_contact: person1, target_contact: org3 }
      let!(:relationship4) { create :person_organization_relationship, source_contact: person2, target_contact: org3 }

      context 'with filter by contact id' do
        it 'sorts relationships by name that is not the filtered contact' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: { filter: { contactId: person1.id }, sort: 'targetContact' },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq relationship3.id
          expect(data[1]['id']).to eq relationship2.id
          expect(data[2]['id']).to eq relationship1.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end

      context 'without filter by contact id' do
        it 'sorts relationships by target first, source second' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: { sort: 'targetContact' },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq relationship4.id
          expect(data[1]['id']).to eq relationship3.id
          expect(data[2]['id']).to eq relationship2.id
          expect(data[3]['id']).to eq relationship1.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end
    end

    context 'with multiple organization organization relationships' do
      let!(:rel1) { create :organization_organization_relationship, source_contact: org2, target_contact: org1 }
      let!(:rel2) { create :organization_organization_relationship, source_contact: org1, target_contact: org3 }
      let!(:rel3) { create :organization_organization_relationship, source_contact: org4, target_contact: org1 }
      let!(:rel4) { create :organization_organization_relationship, source_contact: org2, target_contact: org3 }

      context 'with filter by contact id' do
        it 'sorts relationships by name that is not the filtered contact' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: { filter: { contactId: org1.id }, sort: 'targetContact' },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq rel3.id
          expect(data[1]['id']).to eq rel2.id
          expect(data[2]['id']).to eq rel1.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end

      context 'without filter by contact id' do
        it 'sorts relationships by target first, source second' do
          get(
            CONTACT_RELATIONSHIPS_ENDPOINT,
            params: { sort: 'targetContact' },
            headers: auth_headers
          )

          body = JSON.parse(response.body)
          data = body['data']
          expect(data[0]['id']).to eq rel4.id
          expect(data[1]['id']).to eq rel2.id
          expect(data[2]['id']).to eq rel3.id
          expect(data[3]['id']).to eq rel1.id

          meta = body['meta']
          expect(meta['total-record-count']).to eq ContactRelationship.count
        end
      end
    end
  end
end
