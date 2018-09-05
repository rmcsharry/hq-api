# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe MANDATES_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[admin contacts_write], permitted_mandates: []) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/mandates' do
    subject { -> { post(MANDATES_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:owner) { create(:contact_person) }
      let(:mandate_group1) { create(:mandate_group, group_type: 'organization') }
      let(:mandate_group2) { create(:mandate_group, group_type: 'organization') }
      let!(:user_group) do
        create(
          :user_group,
          users: [user],
          mandate_groups: [mandate_group1, mandate_group2],
          roles: %i[mandates_read mandates_write]
        )
      end
      let(:primary_consultant) { create(:contact_person) }
      let(:secondary_consultant) { create(:contact_person) }
      let(:payload) do
        {
          data: {
            type: 'mandates',
            attributes: {
              'valid-from': '2004-05-29',
              'valid-to': '2015-12-27',
              category: 'wealth_management',
              state: 'prospect'
            },
            relationships: {
              'owners': {
                data: [
                  { id: owner.id, type: 'mandate-members' }
                ]
              },
              'mandate-groups-organizations': {
                data: [
                  { id: mandate_group1.id, type: 'mandate-groups' },
                  { id: mandate_group2.id, type: 'mandate-groups' }
                ]
              },
              'primary-consultant': {
                data: { id: primary_consultant.id, type: 'contacts' }
              },
              'secondary-consultant': {
                data: { id: secondary_consultant.id, type: 'contacts' }
              }
            }
          }
        }
      end

      it 'creates a new mandate' do
        is_expected.to change(Mandate, :count).by(1)
        is_expected.to change(MandateMember, :count).by(1)
        expect(response).to have_http_status(201)
        mandate = Mandate.find(JSON.parse(response.body)['data']['id'])
        expect(mandate.category).to eq 'wealth_management'
        expect(mandate.owners.map(&:contact)).to include(owner)
        expect(mandate.primary_consultant).to eq primary_consultant
        expect(mandate.secondary_consultant).to eq secondary_consultant
        expect(mandate.mandate_groups_organizations).to include(mandate_group1, mandate_group2)
      end
    end
  end

  describe 'GET /v1/mandates' do
    let(:contact) { create(:contact_person) }
    let!(:mandate1) { create(:mandate, primary_consultant: contact) }
    let!(:mandate2) { create(:mandate, secondary_consultant: contact) }
    let!(:mandate3) { create(:mandate, assistant: contact) }
    let!(:mandate4) { create(:mandate, bookkeeper: contact) }
    let!(:mandate5) { create(:mandate, :with_multiple_owners) }
    let!(:user) do
      create(
        :user,
        contact: contact,
        roles: %i[mandates_read],
        permitted_mandates: [
          mandate1,
          mandate2,
          mandate3,
          mandate4
        ]
      )
    end

    context 'authenticated as user' do
      it 'fetches the mandates for user\'s user_id' do
        get(
          MANDATES_ENDPOINT,
          params: {
            filter: { user_id: user.id },
            include: 'assistant,bookkeeper,mandate-groups-organizations,primary-consultant,secondary-consultant'
          },
          headers: auth_headers
        )
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links', 'included'
        expect(body['meta']['record-count']).to eq 4
      end

      it 'only counts accessible records for total-record-count' do
        create_list :mandate, 10

        get(MANDATES_ENDPOINT, params: { filter: { user_id: user.id } }, headers: auth_headers)
        body = JSON.parse(response.body)

        expect(body['meta']['total-record-count']).to eq 4
      end

      it 'fetches 0 mandates for random user_id' do
        get(MANDATES_ENDPOINT, params: { filter: { user_id: 'asdf' } }, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        expect(body['meta']['record-count']).to eq 0
      end

      it 'fetches the mandates even with empty owner name filter' do
        get(
          MANDATES_ENDPOINT,
          params: {
            filter: { owner_name: '' },
            page: { number: 1, size: 5 }
          },
          headers: auth_headers
        )
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        expect(body['meta']['record-count']).to eq 0
      end
    end

    context 'when authenticated via ews', bullet: false do
      let!(:user) do
        user = create(
          :user,
          contact: contact,
          roles: %i[mandates_read],
          permitted_mandates: [
            mandate1,
            mandate2,
            mandate3,
            mandate4
          ]
        )
        user.authenticated_via_ews = true
        user
      end

      it 'can only read category and owner-name of mandates' do
        get(
          MANDATES_ENDPOINT,
          params: {
            filter: { user_id: user.id },
            include: 'assistant,bookkeeper,mandate-groups-organizations,primary-consultant,secondary-consultant'
          },
          headers: auth_headers
        )

        body = JSON.parse(response.body)
        rendered_attributes = body['data'].map do |contact|
          contact['attributes'].keys
        end.flatten.uniq

        expect(rendered_attributes).to eq(%w[category owner-name])
      end
    end
  end

  describe 'GET /v1/mandates/<mandata_id>' do
    let(:contact) { create(:contact_person) }
    let(:mandate_group) { build(:mandate_group, group_type: 'organization') }
    let!(:mandate) { create(:mandate, :with_multiple_owners, mandate_groups: []) }
    let!(:user) do
      create(
        :user,
        contact: contact,
        roles: %i[mandates_read],
        permitted_mandates: [mandate]
      )
    end

    context 'authenticated as user' do
      it 'fetches the mandate' do
        get(
          "#{MANDATES_ENDPOINT}/#{mandate.id}",
          params: {
            filter: { user_id: user.id },
            include: 'mandate-groups-organizations'
          },
          headers: auth_headers
        )
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'included'
        expect(body['data']['relationships']['mandate-groups-organizations']['data'].count).to eq 1
      end
    end
  end

  describe 'GET /v1/mandates/<mandate_id>/versions' do
    let(:user2) { create(:user, first_name: 'Norman', last_name: 'Bates') }
    let(:user3) { create(:user, first_name: 'Shelley', last_name: 'Stewart') }
    let(:original_comment) { 'Test Comment 1' }
    let(:original_mandate_number) { '001' }
    let(:original_state) { 'prospect' }
    let(:updated_comment) { 'Test Comment 2' }
    let(:updated_mandate_number) { '002' }
    let(:updated_state) { 'client' }
    let!(:mandate) do
      create(
        :mandate,
        comment: original_comment,
        mandate_number: original_mandate_number,
        state: original_state
      )
    end
    let!(:user) do
      create(
        :user,
        roles: %i[mandates_read],
        permitted_mandates: [mandate]
      )
    end

    context 'authenticated as user' do
      before do
        PaperTrail.request.whodunnit = user2.id
        mandate.comment = updated_comment
        mandate.mandate_number = updated_mandate_number
        mandate.save!
        PaperTrail.request.whodunnit = user3.id
        mandate.become_client!
      end

      it 'fetches the mandate versions' do
        get("#{MANDATES_ENDPOINT}/#{mandate.id}/versions?sort=-created-at", params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        change1 = body['data'].first['attributes']
        expect(change1['created-at']).to be_present
        expect(change1['changed-by']).to eq 'Shelley Stewart'
        expect(change1['event']).to eq 'update'
        expect(change1['item-type']).to eq 'mandates'
        expect(change1['changes']['aasm-state']).to eq([original_state, updated_state])
        change2 = body['data'].second['attributes']
        expect(change2['created-at']).to be_present
        expect(change2['changed-by']).to eq 'Norman Bates'
        expect(change2['event']).to eq 'update'
        expect(change2['item-type']).to eq 'mandates'
        expect(change2['changes']['comment']).to eq [original_comment, updated_comment]
        expect(change2['changes']['mandate-number']).to eq [original_mandate_number, updated_mandate_number]
      end

      context 'when trying to delete the relationship' do
        let(:payload) do
          {
            data: [{ type: 'versions', id: mandate.versions.first.id }]
          }
        end

        it 'is not allowed', bullet: false do
          delete(
            "#{MANDATES_ENDPOINT}/#{mandate.id}/relationships/versions", params: payload.to_json, headers: auth_headers
          )
          expect(response).to have_http_status(403)
        end
      end

      context 'when trying to update the relationship' do
        let(:payload) do
          {
            data: []
          }
        end

        it 'is not allowed' do
          put(
            "#{MANDATES_ENDPOINT}/#{mandate.id}/relationships/versions", params: payload.to_json, headers: auth_headers
          )
          expect(response).to have_http_status(403)
        end
      end

      context 'when trying to add a relationship' do
        let(:payload) do
          {
            data: [{ type: 'versions', id: user.versions.first.id }]
          }
        end

        it 'is not allowed' do
          post(
            "#{MANDATES_ENDPOINT}/#{mandate.id}/relationships/versions", params: payload.to_json, headers: auth_headers
          )
          expect(response).to have_http_status(403)
        end
      end
    end

    context 'with changes to the bank accounts' do
      let(:bank_account) { create(:bank_account, mandate: mandate, iban: original_iban) }
      let(:original_iban) { 'DE12500105170648489890' }
      let(:updated_iban) { 'DE28500105170648489893' }

      before do
        PaperTrail.request.whodunnit = user2.id
        bank_account.save!
        PaperTrail.request.whodunnit = user3.id
        bank_account.iban = updated_iban
        bank_account.save!
        PaperTrail.request.whodunnit = user2.id
        bank_account.destroy!
      end

      it 'fetches the mandate versions' do
        get("#{MANDATES_ENDPOINT}/#{mandate.id}/versions?sort=-created-at", params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        change1 = body['data'].first['attributes']
        expect(change1['changed-by']).to eq 'Norman Bates'
        expect(change1['created-at']).to be_present
        expect(change1['event']).to eq 'destroy'
        expect(change1['item-type']).to eq 'bank-accounts'
        expect(change1['changes']).to be_empty
        change2 = body['data'].second['attributes']
        expect(change2['changed-by']).to eq 'Shelley Stewart'
        expect(change2['created-at']).to be_present
        expect(change2['event']).to eq 'update'
        expect(change2['item-type']).to eq 'bank-accounts'
        expect(change2['changes']['iban']).to eq [original_iban, updated_iban]
        change3 = body['data'].third['attributes']
        expect(change3['changed-by']).to eq 'Norman Bates'
        expect(change3['created-at']).to be_present
        expect(change3['event']).to eq 'create'
        expect(change3['item-type']).to eq 'bank-accounts'
        expect(change3['changes']['iban']).to eq [nil, original_iban]
      end
    end
  end
end
