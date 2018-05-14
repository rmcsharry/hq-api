# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

DOCUMENTS_ENDPOINT = '/v1/documents'

RSpec.describe DOCUMENTS_ENDPOINT, type: :request do
  let!(:user) { create(:user) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/documents' do
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

  describe 'POST /v1/documents' do
    subject { -> { post(DOCUMENTS_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:mandate) { create(:mandate) }
      let(:payload) do
        {
          data: {
            type: 'documents',
            attributes: {
              'valid-from': '2004-05-29',
              'valid-to': '2015-12-27',
              category: 'contract_hq',
              name: 'HQT Verträge M. Mustermann',
              file: {
                body: Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'))),
                filename: 'hqtrust_beispiel.pdf'
              }
            },
            relationships: {
              owner: {
                data: { id: mandate.id, type: 'mandates' }
              }
            }
          }
        }
      end

      it 'creates a new contact' do
        is_expected.to change(Document, :count).by(1)
        expect(response).to have_http_status(201)
        document = Document.find(JSON.parse(response.body)['data']['id'])
        expect(document.category).to eq 'contract_hq'
        expect(document.name).to eq 'HQT Verträge M. Mustermann'
        expect(document.owner).to eq mandate
        expect(document.uploader).to eq user
        expect(document.file.attached?).to be_truthy
        expect(Base64.encode64(document.file.download)).to eq(
          Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')))
        )
        expect(document.file.filename.to_s).to eq 'hqtrust_beispiel.pdf'
      end
    end
  end
end
