# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

DOCUMENTS_ENDPOINT = '/v1/documents'

RSpec.describe DOCUMENTS_ENDPOINT, type: :request do
  describe 'GET /v1/documents' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    let!(:documents) { create_list(:document, 10) }

    context 'authenticated as user' do
      it 'fetches the documents' do
        get(DOCUMENTS_ENDPOINT, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        expect(body['data'].first['attributes']).to include 'file-url'
        expect(body['meta']['total-record-count']).to eq 10
      end
    end
  end
end
