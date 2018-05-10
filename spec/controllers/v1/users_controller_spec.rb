# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

USERS_ENDPOINT = '/v1/users'

RSpec.describe USERS_ENDPOINT, type: :request do
  describe 'POST /v1/users/invite' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    let(:email) { 'test@hqfinanz.de' }
    subject { -> { post("#{USERS_ENDPOINT}/invite", params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:user_group1) { create(:user_group) }
      let(:user_group2) { create(:user_group) }
      let(:contact) { create(:contact_person) }
      let(:payload) do
        {
          data: {
            type: 'users',
            attributes: {
              email: email
            },
            relationships: {
              'contact': {
                data: { id: contact.id, type: 'contacts' }
              },
              'user-groups': {
                data: [
                  { id: user_group1.id, type: 'user-groups' },
                  { id: user_group2.id, type: 'user-groups' }
                ]
              }
            }
          }
        }
      end

      it 'invites a new user' do
        is_expected.to change(User, :count).by(1)
        expect(response).to have_http_status(202)
        user = User.find_by(email: email)
        expect(user.contact).to eq contact
        expect(user.user_groups).to include(user_group1, user_group2)
      end
    end

    context 'without contact' do
      let(:user_group1) { create(:user_group) }
      let(:user_group2) { create(:user_group) }
      let(:payload) do
        {
          data: {
            type: 'users',
            attributes: {
              email: email
            },
            relationships: {
              'user-groups': {
                data: [
                  { id: user_group1.id, type: 'user-groups' },
                  { id: user_group2.id, type: 'user-groups' }
                ]
              }
            }
          }
        }
      end

      it 'does not create a new user' do
        is_expected.to change(User, :count).by(0)
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq 'The required parameter, contact, is missing.'
      end
    end
  end
end
