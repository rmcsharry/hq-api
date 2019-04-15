# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe TASKS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let!(:user) { create(:user, roles: %w[tasks contacts_read]) }
  let!(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let!(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/tasks/<id>' do
    let!(:person) { create(:contact_person) }
    let!(:task) { create(:contact_birthday_reminder, subject: person, assignees: [user]) }

    it 'can include the polymorphic subject' do
      get("#{TASKS_ENDPOINT}/#{task.id}", params: { include: 'subject' }, headers: auth_headers)
      expect(response).to have_http_status(200)

      body = JSON.parse(response.body)
      expect(body.dig('data', 'relationships', 'subject', 'data', 'id')).not_to be_nil
    end
  end

  describe 'GET /v1/tasks' do
    let!(:task) { create(:task_simple, assignees: [user, user.clone]) }

    it 'returns distinct tasks' do
      get(TASKS_ENDPOINT, headers: auth_headers)

      meta = JSON.parse(response.body).to_hash['meta']
      expect(meta['record-count']).to be(1)
      expect(meta['total-record-count']).to be(1)
    end

    it 'gets along with filters and sort' do
      get(TASKS_ENDPOINT, params: { filter: { state: 'created' }, sort: '-created-at' }, headers: auth_headers)

      meta = JSON.parse(response.body).to_hash['meta']
      expect(meta['record-count']).to be(1)
      expect(meta['total-record-count']).to be(1)
    end
  end
end
