# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe MANDATE_GROUPS_ENDPOINT, type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/mandate-groups' do
    let!(:families) { create_list :mandate_group, 3, group_type: 'family' }
    let!(:organizations) { create_list :mandate_group, 4, group_type: 'organization' }

    context 'as a user with `admin` and `families_read` role' do
      let(:user) { create :user, roles: %i[admin families_read] }

      it 'has total count equal to number of mandate_groups' do
        get(MANDATE_GROUPS_ENDPOINT, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq MandateGroup.count
      end
    end

    context 'as a user with `admin` role' do
      let(:user) { create :user, roles: %i[admin] }

      it 'has total count equal to number of organizations' do
        get(MANDATE_GROUPS_ENDPOINT, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq MandateGroup.organizations.count
      end

      it 'counts correctly when group_type is filtered for organizations' do
        get(MANDATE_GROUPS_ENDPOINT, params: { filter: { group_type: 'organization' } }, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq MandateGroup.organizations.count
      end

      it 'counts correctly when group_type is filtered for families' do
        get(MANDATE_GROUPS_ENDPOINT, params: { filter: { group_type: 'family' } }, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq 0
      end
    end

    context 'as a user with `families_read` role' do
      let(:user) { create :user }
      let!(:user_group) { create :user_group, users: [user], mandate_groups: [], roles: [:families_read] }

      it 'has total count equal to number of families' do
        get(MANDATE_GROUPS_ENDPOINT, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq MandateGroup.families.count
      end

      it 'also counts organizations that are assigned to adjacent user_groups' do
        organization = create :mandate_group, group_type: 'organization'
        create :user_group, users: [user], mandate_groups: [organization], roles: [:families_read]

        get(MANDATE_GROUPS_ENDPOINT, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq(MandateGroup.families.count + 1)
      end

      it 'counts correctly when group_type is filtered for organizations' do
        get(MANDATE_GROUPS_ENDPOINT, params: { filter: { group_type: 'organization' } }, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq 0
      end

      it 'counts correctly when group_type is filtered for families' do
        get(MANDATE_GROUPS_ENDPOINT, params: { filter: { group_type: 'family' } }, headers: auth_headers)
        total_record_count = JSON.parse(response.body)['meta']['total-record-count']

        expect(total_record_count).to eq MandateGroup.families.count
      end
    end
  end

  describe 'POST /v1/mandate-groups' do
    let(:family) { create(:mandate_group, group_type: 'family') }
    let(:mandate) { create :mandate }
    let(:user) { create :user }
    let(:mandate_group) { create :mandate_group, mandates: [mandate] }
    let!(:user_group) do
      create(
        :user_group,
        users: [user],
        mandate_groups: [mandate_group],
        roles: %i[families_write mandates_write]
      )
    end
    let(:payload) do
      {
        data: [
          { id: mandate.id, type: 'mandates' }
        ]
      }
    end
    let(:endpoint) do
      lambda do |auth_headers|
        post "#{MANDATE_GROUPS_ENDPOINT}/#{family.id}/relationships/mandates",
             params: payload.to_json,
             headers: auth_headers
      end
    end

    context 'mandate is not in the family yet' do
      it 'successfully adds the mandate to the mandate group' do
        endpoint.call(auth_headers)
        expect(response).to have_http_status(204)
        expect(mandate_group.mandates).to eq [mandate]
      end
    end

    context 'mandate is in the family already' do
      let(:family) { create(:mandate_group, mandates: [mandate], group_type: 'family') }

      it 'successfully adds the mandate to the mandate group' do
        endpoint.call(auth_headers)
        expect(response).to have_http_status(204)
        expect(mandate_group.mandates).to eq [mandate]
      end
    end

    context 'add two mandates, one of which is in the family already' do
      let(:family) { create(:mandate_group, mandates: [mandate], group_type: 'family') }
      let(:mandate_group) { create :mandate_group, mandates: [mandate, mandate2] }
      let(:mandate2) { create :mandate }
      let(:payload) do
        {
          data: [
            { id: mandate.id, type: 'mandates' },
            { id: mandate2.id, type: 'mandates' }
          ]
        }
      end

      it 'successfully adds the mandate to the mandate group' do
        endpoint.call(auth_headers)
        expect(response).to have_http_status(204)
        expect(mandate_group.mandates).to contain_exactly mandate, mandate2
      end
    end
  end
end
