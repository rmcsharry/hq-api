# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTOR_CASHFLOWS_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[funds_read funds_write]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/investor-cashflows/<id>/finish' do
    let!(:investor_cashflow) { create(:investor_cashflow, state: 'open') }
    subject do
      lambda {
        post(
          "#{INVESTOR_CASHFLOWS_ENDPOINT}/#{investor_cashflow.id}/finish",
          params: {}.to_json,
          headers: auth_headers
        )
      }
    end

    context 'with valid payload' do
      it 'marks the investor cashflow as finished' do
        subject.call
        expect(response).to have_http_status(200)
        expect(investor_cashflow.reload.state).to eq 'finished'
      end
    end

    context 'with cashflow already in state finished' do
      let!(:investor_cashflow) { create(:investor_cashflow, state: 'finished') }

      it 'throws an error' do
        subject.call
        expect(response).to have_http_status(422)
        expect(investor_cashflow.reload.state).to eq 'finished'
      end
    end

    context 'with insufficient rights' do
      let!(:user) { create(:user, roles: %i[funds_read]) }

      it 'throws an error' do
        subject.call
        expect(response).to have_http_status(403)
        expect(investor_cashflow.reload.state).to eq 'open'
      end
    end
  end
end
