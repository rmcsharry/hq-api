# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe TASK_COMMENTS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let!(:user) { create(:user, roles: %w[tasks contacts_read]) }
  let!(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let!(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/task-comments' do
    let!(:task) { create(:task, assignees: [user]) }
    let!(:task_comment) { create(:task_comment, task: task) }

    it 'returns distinct task comments' do
      get(TASK_COMMENTS_ENDPOINT, headers: auth_headers)

      meta = JSON.parse(response.body).to_hash['meta']
      expect(meta['record-count']).to be(1)
      expect(meta['total-record-count']).to be(1)
    end

    it 'gets along with filters and sort' do
      get(
        TASK_COMMENTS_ENDPOINT,
        params: { filter: { task_id: task_comment.task_id }, sort: '-created-at' },
        headers: auth_headers
      )

      meta = JSON.parse(response.body).to_hash['meta']
      expect(meta['record-count']).to be(1)
      expect(meta['total-record-count']).to be(1)
    end
  end
end
