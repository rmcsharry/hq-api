# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/', type: :request do
  describe 'DEBUG /any-endpoint' do
    it 'does not fail for unknown HTTP methods' do
      process 'DEBUG', '/'
      expect(response).to have_http_status(405)
    end
  end
end
