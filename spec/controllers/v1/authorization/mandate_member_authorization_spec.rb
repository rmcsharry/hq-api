# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authorization for', type: :request do
  let!(:record) { create(:mandate_member) }
  include_examples 'simple crud authorization',
                   MANDATE_MEMBERS_ENDPOINT,
                   resource: 'mandate-members',
                   permissions: {
                     destroy: :contacts_destroy,
                     export: :contacts_export,
                     read: :contacts_read,
                     write: :contacts_write
                   },
                   skip: %i[index]

  include_examples 'forbid access for ews authenticated users',
                   MANDATE_MEMBERS_ENDPOINT,
                   resource: 'mandate-members',
                   except: []

  context 'mandate-members' do
    let!(:permitted_mandate) { create(:mandate) }
    let!(:random_mandate) { create(:mandate) }
    let!(:contact) { create(:contact_person) }
    let!(:permitted_mandate_member) { create(:mandate_member, contact: contact, mandate: permitted_mandate) }
    let!(:forbidden_mandate_member) { create(:mandate_member, contact: contact, mandate: random_mandate) }
    let!(:mandate_group) { create(:mandate_group, mandates: [permitted_mandate]) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, permitted_user) }

    def response_data
      JSON.parse(response.body)['data']
    end

    describe '#index' do
      let!(:permitted_user) { create(:user) }
      let(:endpoint) { ->(auth_headers) { get MANDATE_MEMBERS_ENDPOINT, headers: auth_headers } }

      it 'excludes mandate-members that no permissions exist for' do
        endpoint.call(auth_headers)

        expect(response.status).to eq(403)
      end

      describe 'with mandates_read role' do
        let!(:user_group) do
          create(:user_group, users: [permitted_user], mandate_groups: [mandate_group], roles: [:mandates_read])
        end

        it 'includes mandate-members for mandates which the user has permissions for' do
          endpoint.call(auth_headers)

          expect(MandateMember.count).to eq(3)
          expect(response_data.size).to eq(1)
          expect(response_data.first['id']).to eq(permitted_mandate_member.id)
        end
      end
    end
  end
end
