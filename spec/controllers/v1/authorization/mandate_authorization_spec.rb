# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'authorization for', type: :request do
  context 'mandates' do
    let!(:record) { create(:mandate) }
    include_examples 'forbid access for ews authenticated users',
                     MANDATES_ENDPOINT,
                     resource: 'mandates',
                     except: [:index]
  end

  context 'mandates' do
    let!(:permitted_mandate) { create(:mandate, comment: 'permitted') }
    let!(:forbidden_mandate) { create(:mandate, comment: 'forbidden') }
    let!(:permitted_group) { create(:mandate_group, mandates: [permitted_mandate]) }
    let!(:forbidden_group) { create(:mandate_group, mandates: [forbidden_mandate]) }
    let!(:permitted_user) { create(:user) }
    let!(:random_user) { create(:user) }
    let!(:user_group_with_missing_role) do
      create(:user_group, users: [permitted_user], mandate_groups: [forbidden_group], roles: [])
    end
    let!(:user_group_without_mandate_groups) do
      create(:user_group, users: [permitted_user], mandate_groups: [], roles: [:mandates_read])
    end
    let!(:user_group_random_user) do
      create(:user_group, users: [random_user], mandate_groups: [forbidden_group], roles: [:mandates_read])
    end

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get MANDATES_ENDPOINT, headers: auth_headers } }
      let!(:user_group) do
        create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_read])
      end

      permit :mandates_read do |role, response|
        data = JSON.parse(response.body)['data']
        case role
        when :mandates_read
          data.count == 1 && data[0]['attributes']['comment'] == 'permitted'
        end
      end

      describe 'with included mandate-groups-organizations' do
        let(:endpoint) do
          lambda do |auth_headers|
            get MANDATES_ENDPOINT, headers: auth_headers, params: { include: 'mandate-groups-organizations' }
          end
        end
        let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
        let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, permitted_user) }

        it 'only includes each organization once' do
          first_group = create(:mandate_group, mandates: [permitted_mandate], group_type: 'organization')
          second_group = create(:mandate_group, mandates: [permitted_mandate], group_type: 'organization')
          create(
            :user_group,
            users: [permitted_user],
            mandate_groups: [first_group, second_group],
            roles: [:mandates_read]
          )

          endpoint.call(auth_headers)
          mandate = JSON.parse(response.body)['data'].first
          included_ids = mandate['relationships']['mandate-groups-organizations']['data'].map { |group| group['id'] }
          expect(included_ids.size).to eq(included_ids.uniq.size)
        end
      end
    end

    describe '#show' do
      let(:endpoint) do
        ->(auth_headers) { get "#{MANDATES_ENDPOINT}/#{permitted_mandate.id}", headers: auth_headers }
      end
      let!(:user_group) do
        create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_read])
      end
      # this simulates the read role to be set twice which may not cause any issues
      let!(:user_group_duplicate) do
        create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_read])
      end

      describe 'permitted mandate' do
        let(:mandate) { permitted_mandate }

        permit :mandates_read
      end

      describe 'forbidden mandate' do
        let(:mandate) { forbidden_mandate }

        permit # no role permits to see the forbidden mandate
      end
    end

    describe '#create' do
      let(:endpoint) do
        ->(auth_headers) { post MANDATES_ENDPOINT, params: payload.to_json, headers: auth_headers }
      end
      let!(:user_group) do
        create(:user_group, users: [permitted_user], mandate_groups: [], roles: [:mandates_write])
      end
      let(:owner) { create(:contact_person) }
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
              }
            }
          }
        }
      end

      permit :mandates_write
    end

    describe '#update' do
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{MANDATES_ENDPOINT}/#{mandate.id}", params: payload.to_json, headers: auth_headers
        end
      end
      let!(:user_group) do
        create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_write])
      end
      let(:payload) do
        {
          data: {
            attributes: { 'valid-from': '2004-05-30' },
            id: mandate.id,
            type: 'mandates'
          }
        }
      end

      describe 'permitted mandate' do
        let(:mandate) { permitted_mandate }

        permit :mandate_write
      end

      describe 'forbidden mandate' do
        let(:mandate) { forbidden_mandate }

        permit # no role permits to update the forbidden mandate
      end
    end

    describe '#destroy' do
      let(:endpoint) { ->(auth_headers) { delete "#{MANDATES_ENDPOINT}/#{mandate.id}", headers: auth_headers } }
      let!(:user_group) do
        create(:user_group, users: [permitted_user], mandate_groups: [permitted_group], roles: [:mandates_destroy])
      end

      describe 'permitted mandate' do
        let(:mandate) { permitted_mandate }

        permit :mandates_destroy
      end

      describe 'forbidden mandate' do
        let(:mandate) { forbidden_mandate }

        permit # no role permits to destroy the forbidden mandate
      end
    end
  end
end
