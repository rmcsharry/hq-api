# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe FUND_CASHFLOWS_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[funds_read funds_write]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'POST /v1/fund-cashflows' do
    subject do
      lambda {
        post(
          FUND_CASHFLOWS_ENDPOINT,
          params: payload.to_json,
          headers: auth_headers
        )
      }
    end

    let(:fund) { create(:fund) }
    let(:investor1) { create(:investor, :signed, fund: fund) }
    let(:investor2) { create(:investor, :signed, fund: fund) }

    let(:payload) do
      {
        data: {
          type: 'fund-cashflows',
          attributes: {
            'investor-cashflows': [
              {
                investorId: investor1.id,
                capitalCallCompensatoryInterestAmount: 100_000,
                capitalCallGrossAmount: 500_000,
                capitalCallManagementFeesAmount: 50_000,
                distributionCompensatoryInterestAmount: 10_000,
                distributionDividendsAmount: 12_000,
                distributionInterestAmount: 14_000,
                distributionMiscProfitsAmount: 10_000,
                distributionParticipationProfitsAmount: 100_000,
                distributionRecallableAmount: 12_000,
                distributionRepatriationAmount: 250_000,
                distributionStructureCostsAmount: 150_000,
                distributionWithholdingTaxAmount: 25_000
              },
              {
                investorId: investor2.id,
                capitalCallCompensatoryInterestAmount: 100_000,
                capitalCallGrossAmount: 500_000,
                capitalCallManagementFeesAmount: 50_000,
                distributionCompensatoryInterestAmount: 10_000,
                distributionDividendsAmount: 12_000,
                distributionInterestAmount: 14_000,
                distributionMiscProfitsAmount: 10_000,
                distributionParticipationProfitsAmount: 100_000,
                distributionRecallableAmount: 12_000,
                distributionRepatriationAmount: 250_000,
                distributionStructureCostsAmount: 150_000,
                distributionWithholdingTaxAmount: 25_000
              }
            ],
            'valuta-date': Time.zone.today
          },
          relationships: {
            fund: {
              data: { id: fund.id, type: 'funds' }
            }
          }
        }
      }
    end

    context 'with valid payload' do
      it 'creates an fund cashflow with 2 investor cashflows' do
        subject.call
        is_expected.to change(FundCashflow, :count).by(1)
        is_expected.to change(InvestorCashflow, :count).by(2)
        expect(response).to have_http_status(201)
      end
    end

    context 'with investor being from another fund' do
      let(:investor2) { create(:investor, :signed) }

      it 'throws an error' do
        subject.call
        is_expected.to change(FundCashflow, :count).by(0)
        is_expected.to change(InvestorCashflow, :count).by(0)
        expect(response).to have_http_status(422)
      end
    end

    context 'with investor not having signed yet' do
      let(:investor2) { create(:investor, fund: fund, aasm_state: :created) }

      it 'throws an error' do
        subject.call
        is_expected.to change(FundCashflow, :count).by(0)
        is_expected.to change(InvestorCashflow, :count).by(0)
        expect(response).to have_http_status(422)
      end
    end
  end
end
