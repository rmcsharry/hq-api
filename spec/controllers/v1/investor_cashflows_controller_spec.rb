# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTOR_CASHFLOWS_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[funds_read funds_write]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
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

  describe 'GET /v1/investor-cashflows/:id/cashflow-document', bullet: false do
    let(:primary_owner) { create(:contact_person, :with_contact_details) }
    let(:mandate) { create(:mandate, :with_owner, owner: primary_owner, contact_salutation_primary_owner: true) }
    let!(:user) do
      create(
        :user,
        roles: %i[contacts_read funds_read mandates_read],
        permitted_mandates: [mandate]
      )
    end

    let!(:fund) { create(:fund) }
    let!(:investor) do
      create(
        :investor,
        :signed,
        fund: fund,
        mandate: mandate,
        amount_total: 1
      )
    end
    let!(:cashflow_type) { :distribution }
    let!(:fund_cashflow) { create(:fund_cashflow, fund: fund) }
    let!(:investor_cashflow) do
      create(
        :investor_cashflow,
        capital_call_gross_amount: cashflow_type == :distribution ? 0 : 1,
        distribution_dividends_amount: cashflow_type == :distribution ? 1 : 0,
        fund_cashflow: fund_cashflow,
        investor: investor
      )
    end
    let!(:document) do
      category = cashflow_type == :distribution ? :fund_distribution_template : :fund_capital_call_template
      doc = create(
        :fund_template_document,
        category: category,
        owner: fund
      )
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end

    before do
      get(
        "#{INVESTOR_CASHFLOWS_ENDPOINT}/#{investor_cashflow.id}/cashflow-document",
        params: {},
        headers: auth_headers
      )

      tempfile = Tempfile.new
      tempfile.binmode
      tempfile.write response.body
      @response_document = Docx::Document.new(tempfile) unless File.zero?(tempfile)
      tempfile.close
    end

    describe 'with person as primary_owner' do
      context 'with actual template for a capital call' do
        let!(:cashflow_type) { :capital_call }
        let(:document_name) { 'Kapitalabruf_Vorlage.docx' }

        it 'downloads the filled template' do
          expect(response).to have_http_status(201)
          content = @response_document.to_s

          cashflow = investor_cashflow.decorate
          primary_owner = investor.primary_owner.decorate
          primary_address = investor.contact_address

          expect(content).to include('Kapitalabruf')
          expect(content).to include(fund.name)
          expect(content).to include(primary_owner.gender_text)
          expect(content).to include(primary_owner.name)
          expect(content).to include(primary_address.street_and_number)
          expect(content).to include(primary_address.postal_code)
          expect(content).to include(primary_address.city)
          expect(content).to include(fund.currency)
          expect(content).to include(cashflow.net_cashflow_amount)
          expect(content).to include(cashflow.net_cashflow_percentage)

          # Check that there are no un-replaced templating tokens
          expect(content).not_to match(/\{[a-z_\.]+\}/)
        end
      end

      context 'with actual template for a distribution' do
        let!(:cashflow_type) { :distribution }
        let(:document_name) { 'Ausschuettung_Vorlage.docx' }

        it 'downloads the filled template' do
          expect(response).to have_http_status(201)
          content = @response_document.to_s

          cashflow = investor_cashflow.decorate
          primary_owner = investor.primary_owner.decorate
          primary_address = investor.contact_address

          expect(content).to include('Ausschüttung')
          expect(content).to include(fund.name)
          expect(content).to include(primary_owner.gender_text)
          expect(content).to include(primary_owner.name)
          expect(content).to include(primary_address.street_and_number)
          expect(content).to include(primary_address.postal_code)
          expect(content).to include(primary_address.city)
          expect(content).to include(cashflow.net_cashflow_amount)
          expect(content).to include(cashflow.net_cashflow_percentage)

          # Check that there are no un-replaced templating tokens
          expect(content).not_to match(/\{[a-z_\.]+\}/)
        end
      end
    end

    describe 'with organization as primary_owner' do
      let(:primary_owner) { create :contact_organization, :with_contact_details }

      context 'with actual template for a capital call' do
        let!(:cashflow_type) { :capital_call }
        let(:document_name) { 'Kapitalabruf_Vorlage.docx' }

        it 'downloads the filled template' do
          expect(response).to have_http_status(201)
          content = @response_document.to_s

          primary_owner = investor.primary_owner.decorate
          primary_address = investor.contact_address

          expect(content).to include('Kapitalabruf')
          expect(content).to include(fund.name)
          expect(content).to include(primary_owner.name)
          expect(content).to include(primary_address.street_and_number)
          expect(content).to include(primary_address.postal_code)
          expect(content).to include(primary_address.city)
        end
      end

      context 'with actual template for a distribution' do
        let!(:cashflow_type) { :distribution }
        let(:document_name) { 'Ausschuettung_Vorlage.docx' }

        it 'downloads the filled template' do
          expect(response).to have_http_status(201)
          content = @response_document.to_s

          primary_owner = investor.primary_owner.decorate
          primary_address = investor.contact_address

          expect(content).to include('Ausschüttung')
          expect(content).to include(fund.name)
          expect(content).to include(primary_owner.name)
          expect(content).to include(primary_address.street_and_number)
          expect(content).to include(primary_address.postal_code)
          expect(content).to include(primary_address.city)
        end
      end
    end

    context 'with missing funds permissions' do
      let(:document_name) { 'Ausschuettung_Vorlage.docx' }
      let!(:user) do
        create(
          :user,
          roles: %i[contacts_read mandates_read],
          permitted_mandates: [mandate]
        )
      end

      it 'receives a 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'with missing owner, contacts and addresses on mandate' do
      let!(:cashflow_type) { :capital_call }
      let(:document_name) { 'Kapitalabruf_Vorlage.docx' }
      let(:mandate) { create(:mandate) }

      it 'downloads the (only partially) filled template' do
        expect(investor.primary_owner).to be_nil
        expect(investor.primary_contact).to be_nil
        expect(investor.secondary_contact).to be_nil
        expect(investor.legal_address).to be_nil
        expect(investor.contact_address).to be_nil

        expect(response).to have_http_status(201)
        content = @response_document.to_s

        cashflow = investor_cashflow.decorate

        expect(content).to include('Kapitalabruf')
        expect(content).to include(fund.name)
        expect(content).to include(fund.currency)
        expect(content).to include(cashflow.net_cashflow_amount)
        expect(content).to include(cashflow.net_cashflow_percentage)

        # Check that there are no un-replaced templating tokens
        expect(content).not_to match(/\{[a-z_\.]+\}/)
      end
    end
  end
end
