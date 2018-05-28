# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

ACTIVITIES_ENDPOINT = '/v1/activities'

RSpec.describe ACTIVITIES_ENDPOINT, type: :request do
  describe 'POST /v1/activities' do
    let!(:user) { create(:user) }
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
    let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
    subject { -> { post(ACTIVITIES_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:started_at) { 1.day.ago.to_s }
      let(:mandate_1) { create(:mandate) }
      let(:mandate_2) { create(:mandate) }
      let(:payload) do
        {
          data: {
            type: 'activities',
            attributes: {
              description: 'Some description of the telephone call',
              'started-at': started_at,
              title: 'Telephone call',
              'activity-type': 'Activity::Call'
            },
            relationships: {
              mandates: {
                data: [
                  { id: mandate_1.id, type: 'mandates' },
                  { id: mandate_2.id, type: 'mandates' }
                ]
              }
            }
          }
        }
      end

      it 'creates a new activity' do
        is_expected.to change(Activity, :count).by(1)
        expect(response).to have_http_status(201)
        activity = Activity.find(JSON.parse(response.body)['data']['id'])
        expect(activity.description).to eq 'Some description of the telephone call'
        expect(activity.started_at).to eq started_at
        expect(activity.title).to eq 'Telephone call'
        expect(activity.type).to eq 'Activity::Call'
        expect(activity.creator).to eq user
        expect(activity.mandates).to include(mandate_1, mandate_2)
      end
    end

    context 'with documents' do
      let(:payload) do
        {
          data: {
            type: 'activities',
            attributes: {
              description: 'Some description of the telephone call',
              'started-at': 1.day.ago.to_s,
              title: 'Telephone call',
              'activity-type': 'Activity::Call',
              documents: [{
                'valid-from': '2004-05-29',
                'valid-to': '2015-12-27',
                category: 'contract_hq',
                name: 'HQT Verträge M. Mustermann',
                file: {
                  body: Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'))),
                  filename: 'hqtrust_beispiel.pdf'
                }
              }]
            }
          }
        }
      end

      it 'creates documents belonging to the activity' do
        is_expected.to change(Activity, :count).by(1)
        expect(response).to have_http_status(201)
        activity = Activity.find(JSON.parse(response.body)['data']['id'])
        document = activity.documents.first

        expect(document.name).to eq 'HQT Verträge M. Mustermann'
        expect(document.category).to eq 'contract_hq'
        expect(document.owner).to eq activity
        expect(document.uploader).to eq user
        expect(document.file.attached?).to be_truthy
        expect(Base64.encode64(document.file.download)).to eq(
          Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')))
        )
        expect(document.file.filename.to_s).to eq 'hqtrust_beispiel.pdf'
      end
    end

    context 'with invalid documents' do
      let(:payload) do
        {
          data: {
            type: 'activities',
            attributes: {
              description: 'Some description of the telephone call',
              'started-at': 1.day.ago.to_s,
              title: 'Telephone call',
              'activity-type': 'Activity::Call',
              documents: [{
                name: 'HQT Verträge M. Mustermann',
                file: {
                  body: Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'))),
                  filename: 'hqtrust_beispiel.pdf'
                }
              }]
            }
          }
        }
      end

      it 'does not create an activity' do
        is_expected.to change(Activity, :count).by(0)
        is_expected.to change(Document, :count).by(0)
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq 'documents - is invalid'
      end
    end
  end
end
