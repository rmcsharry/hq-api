# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'authorization for', type: :request do
  context 'users' do
    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get USERS_ENDPOINT, headers: auth_headers } }

      permit :admin
    end

    describe '#show' do
      let!(:user) { create(:user) }
      let(:endpoint) { ->(auth_headers) { get "#{USERS_ENDPOINT}/#{user.id}", headers: auth_headers } }

      permit :admin

      describe 'access to themselves' do
        let!(:user) { create(:user, user_groups: []) }
        let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
        let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

        it 'is permitted regardless of their roles' do
          endpoint.call(auth_headers)
          expect(response).not_to have_http_status(403)
        end
      end
    end
  end
end
