# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HEALTHCHECK_ENDPOINT, type: :request do
  describe 'GET /health' do
    it 'returns with 200' do
      get(HEALTHCHECK_ENDPOINT, params: {}, headers: {})
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)
      expect(body).to eq('ok' => true, 'test' => 'new3')
    end
  end
end
