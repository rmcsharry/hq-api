# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe DOCUMENTS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let!(:mandate) { create(:mandate) }
  let!(:user) do
    create(
      :user,
      roles: %i[contacts_read contacts_write contacts_destroy mandates_read mandates_write],
      permitted_mandates: [mandate]
    )
  end
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
  let(:mandate) { create(:mandate) }

  describe 'GET /v1/documents' do
    let!(:documents) { create_list(:document, 10, owner: mandate) }

    context 'authenticated as user' do
      it 'fetches the documents' do
        get(DOCUMENTS_ENDPOINT, params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta', 'links'
        expect(body['data'].first['attributes']).to include 'file-url'
        expect(body['meta']['total-record-count']).to eq 10
      end

      it 'fetches only mandate related documents' do
        get("/v1/mandates/#{mandate.id}/documents", params: { page: { number: 1, size: 5 } }, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta'
        expect(body['data'].count).to eq 5
        expect(body['meta']['record-count']).to eq 10
      end
    end
  end

  describe 'GET document file' do
    let(:document) { create(:document) }

    context 'not authenticated as user' do
      it 'responds with 401' do
        get(Rails.application.routes.url_helpers.rails_blob_url(document.file))
        expect(response).to have_http_status(401)
      end
    end

    context 'authenticated as user' do
      it 'fetches the documents' do
        get(Rails.application.routes.url_helpers.rails_blob_url(document.file), params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        expect(Base64.encode64(response.body)).to eq(
          Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')))
        )
      end
    end
  end

  describe 'POST /v1/documents' do
    let(:headers) { { 'Content-Type' => 'multipart/related' } }
    subject { -> { post(DOCUMENTS_ENDPOINT, params: payload, headers: auth_headers) } }

    context 'with valid payload' do
      let(:file) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'),
          'application/pdf'
        )
      end
      let(:payload) do
        {
          data: {
            type: 'documents',
            attributes: {
              'valid-from': '2004-05-29',
              'valid-to': '2015-12-27',
              category: 'contract_hq',
              name: 'HQT Verträge M. Mustermann',
              file: 'cid:file:0'
            },
            relationships: {
              owner: {
                data: { id: mandate.id, type: 'mandates' }
              }
            }
          }.to_json,
          'file:0': file
        }
      end

      it 'creates a new document' do
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
        expect(document.file.filename.to_s).to eq 'hqtrust_sample.pdf'
      end
    end
  end

  describe 'DELETE /v1/documents' do
    subject { -> { delete("#{DOCUMENTS_ENDPOINT}/#{document.id}", params: {}, headers: auth_headers) } }

    context 'with valid payload' do
      let!(:document) { create(:document) }

      before do
        document.file.analyze
      end

      it 'deletes a document' do
        clear_enqueued_jobs
        is_expected.to change(Document, :count).by(-1)
        expect(response).to have_http_status(204)
        expect(ActiveStorage::PurgeJob).to have_been_enqueued
      end
    end
  end
end
