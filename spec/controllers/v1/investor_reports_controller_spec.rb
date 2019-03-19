# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTOR_REPORTS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let(:random_user) { create(:user) }
  let(:tax_detail) { create :tax_detail, de_tax_number: '21/815/08150' }
  let(:contact_person) do
    create(:contact_person, :with_mandate, mandate: mandate, user: random_user, tax_detail: tax_detail)
  end
  let!(:mandate) { create(:mandate) }
  let!(:user) do
    create(
      :user,
      roles: %i[contacts_read funds_read mandates_read],
      permitted_mandates: [mandate]
    )
  end
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/investor-reports/:id/quarterly-report-document' do
    let!(:fund) { create(:fund) }
    let!(:investor) { create(:investor, fund: fund, mandate: mandate, primary_owner: primary_owner) }
    let!(:fund_report) { create(:fund_report, fund: fund, investors: [investor]) }
    let!(:investor_report) { InvestorReport.find_by! investor: investor, fund_report: fund_report }
    let!(:document) do
      doc = create(
        :fund_template_document,
        category: :fund_quarterly_report_template,
        owner: fund
      )
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end
    let(:document_name) { 'Quartalsbericht_Vorlage.docx' }

    before do
      get(
        "#{INVESTOR_REPORTS_ENDPOINT}/#{investor_report.id}/quarterly-report-document",
        params: {},
        headers: auth_headers
      )
    end

    def response_document
      tempfile = Tempfile.new 'filled-report'
      tempfile.binmode
      tempfile.write response.body
      docx = Docx::Document.new(tempfile.path) unless File.zero?(tempfile)
      tempfile.close
      docx
    end

    context 'with person as primary owner' do
      let(:primary_owner) { create(:contact_person, :with_mandate, mandate: mandate) }

      it 'downloads the filled template' do
        expect(response).to have_http_status(201)
        content = response_document.to_s

        primary_owner = investor.primary_owner.decorate

        expect(content).to include(fund.name)
        expect(content).to include(primary_owner.name)
      end
    end

    context 'with organization as primary owner' do
      let(:primary_owner) { create(:contact_organization, :with_mandate, mandate: mandate) }

      it 'downloads the filled template' do
        expect(response).to have_http_status(201)
        content = response_document.to_s

        primary_owner = investor.primary_owner.decorate

        expect(content).to include(fund.name)
        expect(content).to include(primary_owner.name)
      end
    end

    context 'with missing template' do
      let(:document) { nil }
      let(:primary_owner) { create(:contact_person, :with_mandate, mandate: mandate) }

      it 'returns `not_found` error code' do
        expect(response).to have_http_status(404)
      end
    end

    context 'with pdf template' do
      let!(:document) do
        doc = create(
          :fund_template_document,
          category: :fund_quarterly_report_template,
          owner: fund
        )
        doc.file.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')),
          filename: 'sample.pdf',
          content_type: Mime[:pdf].to_s
        )
        doc
      end
      let(:primary_owner) { create(:contact_person, :with_mandate, mandate: mandate) }

      it 'returns unmodified pdf document' do
        expected_document = File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'))
        expect(Base64.encode64(expected_document.read)).to eq(Base64.encode64(response.body))
      end
    end
  end
end
