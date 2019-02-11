# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe ACTIVITIES_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let!(:mandate_1) { create(:mandate) }
  let!(:mandate_2) { create(:mandate) }
  let!(:user) do
    create(
      :user,
      roles: %i[contacts_read contacts_write mandates_read mandates_write],
      permitted_mandates: [mandate_1, mandate_2]
    )
  end
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  before(:all) do
    @queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end

  after(:all) do
    ActiveJob::Base.queue_adapter = @queue_adapter
  end

  describe 'GET /v1/activities' do
    let(:mandate_group) { create(:mandate_group) }
    let!(:mandate_1) { create(:mandate, mandate_groups: [mandate_group]) }
    let(:mandate_2) { create(:mandate, mandate_groups: [mandate_group]) }
    let!(:activities) { create_list(:activity_call, 3, mandates: [mandate_1, mandate_2]) }
    let!(:more_activities) { create_list(:activity_call, 2) }
    let!(:even_more_activities) { create_list(:activity_call, 3, mandates: [mandate_1]) }
    let!(:document_1) { create(:document, owner: activities.first) }
    let!(:document_2) { create(:document, owner: activities.first) }

    context 'authenticated as user' do
      it 'fetches the activities' do
        get(ACTIVITIES_ENDPOINT, params: {}, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta'
      end
    end

    context 'filtered by mandate group' do
      let!(:params) do
        { page: { number: 1, size: 5 }, filter: { mandate_group_id: mandate_group.id }, sort: '-createdAt' }
      end

      it 'fetches only mandate related activities' do
        get(ACTIVITIES_ENDPOINT, params: params, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta'
        expect(body['data'].count).to eq 5
        expect(body['meta']['record-count']).to eq 6
      end
    end

    context 'filtered by mandate' do
      let!(:params) { { page: { number: 1, size: 5 }, filter: { mandate_id: mandate_1.id } } }

      it 'fetches only mandate related activities' do
        get(ACTIVITIES_ENDPOINT, params: params, headers: auth_headers)
        expect(response).to have_http_status(200)
        body = JSON.parse(response.body)
        expect(body.keys).to include 'data', 'meta'
        expect(body['data'].count).to eq 5
        expect(body['meta']['record-count']).to eq 6
      end

      context 'with includes' do
        let(:include_params) { params.merge(include: 'documents,creator.contact,contacts,mandates') }
        let(:ordered_activity_ids) { (activities + even_more_activities).map(&:id).sort }

        it 'fetches the activities on page 1' do
          merged_params = include_params.merge(page: { number: 1, size: 5 })
          get(ACTIVITIES_ENDPOINT, params: merged_params, headers: auth_headers)
          expect(response).to have_http_status(200)
          body = JSON.parse(response.body)
          expect(body.keys).to include 'data', 'meta', 'included', 'links'
          expect(body['meta']['record-count']).to eq 6
        end

        it 'fetches the activities on page 2' do
          merged_params = include_params.merge(page: { number: 2, size: 5 })
          get(ACTIVITIES_ENDPOINT, params: merged_params, headers: auth_headers)
          expect(response).to have_http_status(200)
          body = JSON.parse(response.body)
          expect(body.keys).to include 'data', 'meta', 'links'
          expect(body['data'].length).to eq 1
          expect(body['data'].map { |d| d['id'] }).to eq ordered_activity_ids.slice(5, 1)
          expect(body['meta']['record-count']).to eq 6
        end

        it 'fetches the documents once' do
          merged_params = include_params.merge(page: { number: 1, size: 6 })
          get(ACTIVITIES_ENDPOINT, params: merged_params, headers: auth_headers)
          expect(response).to have_http_status(200)
          body = JSON.parse(response.body)
          expect(body.keys).to include 'data', 'meta', 'included', 'links'
          expect(body['data'].map { |d| d['id'] }).to eq ordered_activity_ids
          document_activity = body['data'].select { |activity| activity['id'] == activities.first.id }.first
          expect(document_activity['relationships']['documents']['data'].count).to eq 2
          expect(body['meta']['record-count']).to eq 6
        end
      end
    end
  end

  describe 'POST /v1/activities' do
    subject { -> { post(ACTIVITIES_ENDPOINT, params: payload.to_json, headers: auth_headers) } }

    context 'with valid payload' do
      let(:started_at) { 1.day.ago.to_s }
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

    context 'with valid payload for a Note' do
      let(:payload) do
        {
          data: {
            type: 'activities',
            attributes: {
              description: 'Some description of the note',
              title: 'Note',
              'activity-type': 'Activity::Note'
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
        expect(activity.description).to eq 'Some description of the note'
        expect(activity.title).to eq 'Note'
        expect(activity.type).to eq 'Activity::Note'
        expect(activity.creator).to eq user
        expect(activity.mandates).to include(mandate_1, mandate_2)
      end
    end

    context 'with documents' do
      subject { -> { post(ACTIVITIES_ENDPOINT, params: payload, headers: auth_headers) } }
      let(:headers) { { 'Content-Type' => 'multipart/related' } }
      let(:file) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'),
          'application/pdf'
        )
      end
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
                file: 'cid:file:0'
              }]
            }
          }.to_json,
          'file:0': file
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
        expect(document.file.filename.to_s).to eq 'hqtrust_sample.pdf'
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
        expect(JSON.parse(response.body)['errors'].first['detail']).to eq(
          'documents - ist nicht gültig'
        )
      end
    end

    context 'from outlook add-in' do
      let(:payload) do
        {
          data: {
            type: 'activities',
            attributes: {
              'activity-type': activity_type,
              'ews-id': 'ewsid',
              'ews-token': 'token',
              'ews-url': 'https://ews.shr.ps/',
              'started-at': 1.day.ago.to_s,
              description: 'Email body',
              title: 'Email subject'
            },
            relationships: {
              mandates: {
                data: [
                  { id: mandate_1.id, type: 'mandates' }
                ]
              }
            }
          }
        }
      end

      before do
        clear_enqueued_jobs
      end

      context 'for activity email' do
        let(:activity_type) { 'Activity::Email' }

        it 'triggers job to fetch the mail as .eml file' do
          allow_any_instance_of(FetchEmailJob).to receive(:fetch_email) {
            Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'emails', 'call.eml')))
          }
          is_expected.to change(Activity, :count).by(1)
          expect(response).to have_http_status(201)
          expect(FetchEmailJob).to have_been_enqueued
        end
      end

      context 'for activity meeting' do
        let(:activity_type) { 'Activity::Meeting' }

        it 'does not trigger job to fetch the mail as .eml file' do
          is_expected.to change(Activity, :count).by(1)
          expect(response).to have_http_status(201)
          expect(FetchEmailJob).to_not have_been_enqueued
        end
      end
    end
  end

  describe 'PATCH /v1/activities' do
    subject { -> { patch("#{ACTIVITIES_ENDPOINT}/#{activity.id}", params: payload.to_json, headers: auth_headers) } }

    context 'changes call to note' do
      let(:started_at) { 1.day.ago.to_s }
      let!(:activity) { create(:activity_call, started_at: started_at, mandates: [mandate_1]) }
      let(:payload) do
        {
          data: {
            type: 'activities',
            id: activity.id,
            attributes: {
              description: 'Some description of the note',
              title: 'Note',
              'activity-type': 'Activity::Note'
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

      it 'updates the activity' do
        expect(activity.type).to eq 'Activity::Call'
        expect(activity.started_at).to eq started_at
        is_expected.to change(Activity, :count).by(0)
        expect(response).to have_http_status(200)
        updated_activity = Activity.find(activity.id)
        expect(updated_activity.description).to eq 'Some description of the note'
        expect(updated_activity.started_at).to eq started_at
        expect(updated_activity.title).to eq 'Note'
        expect(updated_activity.type).to eq 'Activity::Note'
        expect(updated_activity.creator).to_not eq user
        expect(updated_activity.mandates).to include(mandate_1, mandate_2)
      end
    end
  end
end
