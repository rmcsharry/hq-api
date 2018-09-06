# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'authorization for', type: :request do
  context 'users' do
    let!(:record) { create(:user) }
    include_examples 'forbid access for ews authenticated users',
                     USERS_ENDPOINT,
                     resource: 'users',
                     except: []
  end

  context 'users' do
    let!(:user) { create(:user) }
    let!(:foreign_user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

    describe '#index' do
      let(:endpoint) { ->(auth_headers) { get USERS_ENDPOINT, headers: auth_headers } }

      permit :admin

      describe '(xlsx request)' do
        let(:endpoint) { ->(h) { get USERS_ENDPOINT, headers: xlsx_headers(h) } }

        permit :admin
      end
    end

    describe '#show' do
      let(:endpoint) { ->(auth_headers) { get "#{USERS_ENDPOINT}/#{user.id}", headers: auth_headers } }

      permit :admin

      it 'permits access to themselves regardless of their roles' do
        endpoint.call(auth_headers)
        expect(response).to have_http_status(200)
      end

      describe 'access to other users', bullet: false do
        let(:endpoint) { ->(auth_headers) { get "#{USERS_ENDPOINT}/#{foreign_user.id}", headers: auth_headers } }

        it 'is not permitted' do
          endpoint.call(auth_headers)
          expect(response).to have_http_status(403)
        end
      end

      describe '(xlsx request)' do
        let(:endpoint) { ->(h) { get "#{USERS_ENDPOINT}/#{user.id}", headers: xlsx_headers(h) } }

        permit :admin
      end
    end

    describe '#update', bullet: false do
      let!(:user_group) { create(:user_group) }
      let(:endpoint) do
        lambda do |auth_headers|
          patch "#{USERS_ENDPOINT}/#{user.id}", params: payload.to_json, headers: auth_headers
        end
      end
      let(:payload) do
        {
          data: {
            id: user.id,
            type: 'users',
            attributes: {
              comment: 'updated comment'
            }
          }
        }
      end

      permit :admin

      describe '(xlsx request)' do
        let(:endpoint) do
          lambda do |h|
            patch "#{USERS_ENDPOINT}/#{user.id}", params: payload.to_json, headers: xlsx_headers(h)
          end
        end

        permit # none
      end

      it 'permits updating themselves regardless of their roles' do
        endpoint.call(auth_headers)
        expect(response).to have_http_status(200)
      end

      describe 'access to other users', bullet: false do
        let(:endpoint) do
          lambda do |auth_headers|
            patch "#{USERS_ENDPOINT}/#{foreign_user.id}", params: payload.to_json, headers: auth_headers
          end
        end
        let(:payload) do
          {
            data: {
              id: foreign_user.id,
              type: 'users',
              attributes: {
                comment: 'updated comment'
              }
            }
          }
        end

        it 'is not permitted' do
          endpoint.call(auth_headers)
          expect(response).to have_http_status(403)
        end
      end

      describe 'relationships', bullet: false do
        let(:endpoint) do
          lambda do |auth_headers|
            post "#{USERS_ENDPOINT}/#{user.id}/relationships/user-groups",
                 params: payload.to_json,
                 headers: auth_headers
          end
        end
        let(:payload) do
          {
            data: [{
              id: user_group.id,
              type: 'user_groups'
            }]
          }
        end

        permit :admin

        it 'is not permitted for own record if user isn\'t an admin' do
          endpoint.call(auth_headers)
          expect(response).to have_http_status(403)
        end
      end
    end
  end
end
