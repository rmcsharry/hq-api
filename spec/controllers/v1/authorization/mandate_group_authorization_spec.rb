# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'authorization for', type: :request do
  context 'mandate-groups' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    let!(:organization) { create(:mandate_group, group_type: 'organization') }
    let!(:family) { create(:mandate_group, group_type: 'family') }

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get MANDATE_GROUPS_ENDPOINT, headers: auth_headers } }

      permit_all do |role, response|
        data = JSON.parse(response.body)['data']
        case role
        when :admin
          data.size == 1 && data.all? do |mandate_group|
            mandate_group['attributes']['group-type'] == 'organization'
          end
        when :families_read
          data.size == 1 && data.any? do |mandate_group|
            mandate_group['attributes']['group-type'] == 'family'
          end
        else
          data.empty?
        end
      end

      describe 'organization in assigned user_groups' do
        let!(:user_group) do
          create(
            :user_group,
            users: [user],
            mandate_groups: [organization],
            roles: []
          )
        end

        it 'is permitted to be read' do
          endpoint.call(auth_headers)
          data = JSON.parse(response.body)['data']

          expect(response).not_to have_http_status(403)
          expect(data.size).to eq(1)
          expect(data.first['attributes']['group-type']).to eq('organization')
        end
      end
    end

    context 'with group_type "organization"' do
      describe '#show' do
        let(:endpoint) do
          ->(auth_headers) { get "#{MANDATE_GROUPS_ENDPOINT}/#{organization.id}", headers: auth_headers }
        end

        permit :admin

        describe 'with families_read permission' do
          let!(:user_group) do
            create(
              :user_group,
              users: [user],
              mandate_groups: [organization],
              roles: %i[families_read]
            )
          end

          it 'is permitted to be read' do
            endpoint.call(auth_headers)

            expect(response).not_to have_http_status(403)
          end
        end
      end

      describe '#create' do
        let(:endpoint) do
          ->(auth_headers) { post MANDATE_GROUPS_ENDPOINT, params: payload.to_json, headers: auth_headers }
        end
        let(:payload) do
          { data: { type: 'mandate-groups', attributes: { 'group-type': 'organization', name: 'o' } } }
        end

        permit :admin
      end

      describe '#update' do
        let(:endpoint) do
          lambda do |auth_headers|
            patch "#{MANDATE_GROUPS_ENDPOINT}/#{organization.id}", params: payload.to_json, headers: auth_headers
          end
        end
        let(:payload) do
          {
            data: {
              attributes: { 'group-type': 'organization', name: 'o' },
              id: organization.id,
              type: 'mandate-groups'
            }
          }
        end

        permit :admin
      end

      describe '#destroy' do
        let(:endpoint) do
          ->(auth_headers) { delete "#{MANDATE_GROUPS_ENDPOINT}/#{organization.id}", headers: auth_headers }
        end

        permit :admin
      end
    end

    context 'with group_type "family"' do
      describe '#show' do
        let(:endpoint) { ->(auth_headers) { get "#{MANDATE_GROUPS_ENDPOINT}/#{family.id}", headers: auth_headers } }

        permit :families_read
      end

      describe '#create' do
        let(:endpoint) do
          ->(auth_headers) { post MANDATE_GROUPS_ENDPOINT, params: payload.to_json, headers: auth_headers }
        end
        let(:payload) do
          { data: { type: 'mandate-groups', attributes: { 'group-type': 'family', name: 'f' } } }
        end

        permit :families_write
      end

      describe '#update' do
        let(:endpoint) do
          lambda do |auth_headers|
            patch "#{MANDATE_GROUPS_ENDPOINT}/#{family.id}", params: payload.to_json, headers: auth_headers
          end
        end
        let(:payload) do
          {
            data: {
              attributes: { 'group-type': 'family', name: 'f' },
              id: family.id,
              type: 'mandate-groups'
            }
          }
        end

        permit :families_write

        describe 'mandates relationship' do
          let(:endpoint) do
            lambda do |auth_headers|
              post "#{MANDATE_GROUPS_ENDPOINT}/#{family.id}/relationships/mandates",
                   params: payload.to_json,
                   headers: auth_headers
            end
          end
          let(:mandate) { create :mandate }
          let(:mandate_group) { create :mandate_group, mandates: [mandate] }
          let!(:user_group) do
            create :user_group,
                   users: [user],
                   mandate_groups: [mandate_group],
                   roles: %i[families_write mandates_write]
          end
          let(:payload) do
            {
              data: [
                {
                  id: mandate.id,
                  type: 'mandates'
                }
              ]
            }
          end

          it 'is possible to attach mandates' do
            endpoint.call(auth_headers)
            expect(response).to have_http_status(204)
          end
        end
      end

      describe '#destroy' do
        let(:endpoint) { ->(auth_headers) { delete "#{MANDATE_GROUPS_ENDPOINT}/#{family.id}", headers: auth_headers } }

        permit :families_destroy
      end
    end
  end
end
