# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe FUND_CASHFLOWS_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[funds_read funds_write]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
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

  [
    'archived-documents',
    'regenerated-documents'
  ].each do |action|
    describe "GET /v1/fund-cashflows/:id/#{action}", bullet: false do
      let(:fund) { create(:fund, name: 'Fund') }
      let(:contact_person1) { create(:contact_person, first_name: 'First', last_name: 'Last') }
      let(:contact_person2) { create(:contact_person, first_name: 'Fore', last_name: 'Family') }
      let(:mandate1) { create(:mandate, :with_multiple_owners, owner: contact_person1) }
      let(:mandate2) { create(:mandate, :with_multiple_owners, owner: contact_person2) }
      let(:investor1) { create(:investor, :signed, fund: fund, mandate: mandate1) }
      let(:investor2) { create(:investor, :signed, fund: fund, mandate: mandate2) }
      let!(:fund_cashflow) { create(:fund_cashflow, fund: fund, number: 1, valuta_date: Date.new(2019, 3, 1)) }
      let!(:investor_cashflow1) do
        create(
          :investor_cashflow,
          capital_call_gross_amount: 0,
          distribution_dividends_amount: 1,
          fund_cashflow: fund_cashflow,
          investor: investor1
        )
      end
      let!(:investor_cashflow2) do
        create(
          :investor_cashflow,
          capital_call_gross_amount: 0,
          distribution_dividends_amount: 1,
          fund_cashflow: fund_cashflow,
          investor: investor2
        )
      end
      let!(:document) do
        doc = create(
          :fund_template_document,
          category: :fund_distribution_template,
          owner: fund
        )
        doc.file.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'docx', 'Ausschuettung_Vorlage.docx')),
          filename: 'distribution.docx',
          content_type: Mime[:docx].to_s
        )
        doc
      end

      before do
        get(
          "#{FUND_CASHFLOWS_ENDPOINT}/#{fund_cashflow.id}/#{action}",
          params: {},
          headers: auth_headers
        )

        tempfile = Tempfile.new
        tempfile.binmode
        tempfile.write response.body
        @response_archive = Zip::File.open(tempfile.path) unless File.zero?(tempfile)
        tempfile.close
      end

      context 'with proper permissions' do
        let!(:user) do
          create(
            :user,
            roles: %i[contacts_read funds_read mandates_read],
            permitted_mandates: [mandate1, mandate2]
          )
        end

        it 'downloads archive with two .docx files inside' do
          expect(response).to have_http_status(201)

          expect(@response_archive.size).to eq(2)
          file_names = @response_archive.entries.map { |e| e.name.force_encoding('UTF-8') }
          expect(file_names).to(
            match_array(
              [
                '190301_Anschreiben_Ausschuettung_Fund_Family, Fore und Guntersen, Thomas_' \
                "#{investor_cashflow2.id[0..7]}.docx",
                '190301_Anschreiben_Ausschuettung_Fund_Guntersen, Thomas und Last, First_' \
                "#{investor_cashflow1.id[0..7]}.docx"
              ]
            )
          )
        end
      end

      context 'with missing permissions' do
        let!(:user) do
          create(
            :user,
            roles: %i[contacts_read mandates_read],
            permitted_mandates: [mandate1, mandate2]
          )
        end

        it 'receives a 403' do
          expect(response).to have_http_status(403)
        end
      end
    end
  end

  describe 'PATCH /v1/fund-cashflows/<id>', bullet: false do
    subject do
      lambda {
        patch(
          "#{FUND_CASHFLOWS_ENDPOINT}/#{fund_cashflow.id}",
          params: payload.to_json,
          headers: auth_headers
        )
      }
    end

    let(:fund) { create(:fund) }
    let(:investor1) { create(:investor, :signed, fund: fund) }
    let(:investor2) { create(:investor, :signed, fund: fund) }
    let(:other_investor) { investor2 }
    let(:fund_cashflow) { create(:fund_cashflow, fund: fund) }
    let!(:investor_cashflow1) do
      create(:investor_cashflow, :capital_call, fund_cashflow: fund_cashflow, investor: investor1)
    end
    let!(:investor_cashflow2) do
      create(:investor_cashflow, :capital_call, fund_cashflow: fund_cashflow, investor: investor2)
    end
    let(:investor_cashflows) do
      [
        {
          investorId: investor1.id,
          capitalCallCompensatoryInterestAmount: 100_000,
          capitalCallGrossAmount: 500_000,
          capitalCallManagementFeesAmount: 50_000
        },
        {
          investorId: other_investor.id,
          capitalCallCompensatoryInterestAmount: 100_000,
          capitalCallGrossAmount: 500_000,
          capitalCallManagementFeesAmount: 50_000
        }
      ]
    end

    let(:payload) do
      {
        data: {
          type: 'fund-cashflows',
          id: fund_cashflow.id,
          attributes: {
            'investor-cashflows': investor_cashflows,
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
      it 'updates the fund cashflow with both investor cashflows' do
        expect(fund_cashflow.net_cashflow_amount).to eq(-600_000)
        subject.call
        is_expected.to change(FundCashflow, :count).by(0)
        is_expected.to change(InvestorCashflow, :count).by(0)
        expect(response).to have_http_status(200)
        expect(fund_cashflow.reload.net_cashflow_amount).to eq(-1_300_000)
      end
    end

    context 'with empty investor cashflows' do
      let(:investor_cashflows) { [] }

      it 'throws an error' do
        subject.call
        is_expected.to change(FundCashflow, :count).by(0)
        expect(response).to have_http_status(200)
        expect(InvestorCashflow.count).to eq 0
        expect(fund_cashflow.reload.net_cashflow_amount).to eq 0
      end
    end

    context 'with investor being from another fund' do
      let(:other_investor) { create(:investor, :signed) }

      it 'throws an error' do
        subject.call
        is_expected.to change(FundCashflow, :count).by(0)
        is_expected.to change(InvestorCashflow, :count).by(0)
        expect(response).to have_http_status(422)
      end
    end
  end
end
