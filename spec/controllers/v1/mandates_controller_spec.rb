# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

MANDATES_ENDPOINT = '/v1/mandates'

RSpec.describe MANDATES_ENDPOINT, type: :request do
  describe 'POST /v1/mandates' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    subject { -> { post(MANDATES_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:owner) { create(:contact_person) }
      let(:mandate_group1) { create(:mandate_group, group_type: 'organization') }
      let(:mandate_group2) { create(:mandate_group, group_type: 'organization') }
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

      it 'creates a new contact' do
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
end
