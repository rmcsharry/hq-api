# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTORS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let(:random_user) { create(:user) }
  let(:tax_detail) { create :tax_detail, de_tax_number: '21/815/08150' }
  let(:contact_person) { create(:contact_person, user: random_user, tax_detail: tax_detail) }
  let(:mandate) { create(:mandate) }
  let!(:mandate_member) do
    create(:mandate_member, mandate: mandate, contact: contact_person, member_type: :owner)
  end
  let!(:user) do
    create(
      :user,
      roles: %i[contacts_read funds_read mandates_read],
      permitted_mandates: [mandate]
    )
  end
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/investors/:id/filled-fund-subscription-agreement' do
    let(:primary_contact) { create(:contact_person) }
    let(:secondary_contact) { create(:contact_person) }
    let!(:fund) { create(:fund) }
    let!(:investor) do
      create(
        :investor,
        fund: fund,
        mandate: mandate,
        primary_contact: primary_contact,
        primary_owner: contact_person,
        secondary_contact: secondary_contact
      )
    end
    let!(:document) do
      doc = create(
        :fund_template_document,
        category: :fund_subscription_agreement_template,
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
      get("#{INVESTORS_ENDPOINT}/#{investor.id}/filled-fund-subscription-agreement", params: {}, headers: auth_headers)

      tempfile = Tempfile.new 'filled-agreement'
      tempfile.binmode
      tempfile.write response.body
      @response_document = Docx::Document.new(tempfile.path) unless File.zero?(tempfile)
      tempfile.close
    end

    context 'with actual template' do
      let(:document_name) { '20181219-Zeichnungsschein_Vorlage.docx' }

      it 'downloads the filled template' do
        expect(response).to have_http_status(201)
        content = @response_document.to_s

        primary_owner = investor.primary_owner.decorate

        expect(content).to include(fund.name)
        expect(content).to include(primary_owner.name)
        expect(content).to include(primary_contact.decorate.name)
        expect(content).to include(secondary_contact.decorate.name)
        expect(content).to include('DE 21/815/08150')

        # Check that there are no un-replaced templating tokens
        expect(content).not_to match(/\{[a-z_\.]+\}/)
      end
    end

    context 'with missing funds permissions' do
      let(:document_name) { '20181219-Zeichnungsschein_Vorlage.docx' }
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

    context 'with malicious template' do
      let(:document_name) { 'hqtrust_sample_unprivileged_access.docx' }

      it 'does not receive the encrypted password' do
        expect(response).to have_http_status(201)

        expect(@response_document.to_s).not_to match(/Encrypted password: [a-zA-Z0-9\$]+/)
      end
    end
  end

  describe 'GET /v1/investors/:id/filled-fund-quarterly-report' do
    let!(:fund) { create(:fund) }
    let!(:investor) { create(:investor, fund: fund, mandate: mandate, primary_owner: primary_owner) }
    let!(:fund_report) { create(:fund_report, fund: fund, investors: [investor]) }
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
    let(:document_name) { '20181219-Quartalsbericht_Vorlage.docx' }

    before do
      get(
        "#{INVESTORS_ENDPOINT}/#{investor.id}/filled-fund-quarterly-report?fund_report_id=#{fund_report.id}",
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
      let(:primary_owner) { create(:contact_person) }

      it 'downloads the filled template' do
        expect(response).to have_http_status(201)
        content = response_document.to_s

        primary_owner = investor.primary_owner.decorate

        expect(content).to include(fund.name)
        expect(content).to include(primary_owner.name)
      end
    end

    context 'with organization as primary owner' do
      let(:primary_owner) { create(:contact_organization) }

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
      let(:primary_owner) { create(:contact_person) }

      it 'returns `not_found` error code' do
        expect(response).to have_http_status(404)
      end
    end

    context 'with missing template', bullet: false do
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
      let(:primary_owner) { create(:contact_person) }

      it 'returns unmodified pdf document' do
        expected_document = File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf'))
        expect(Base64.encode64(expected_document.read)).to eq(Base64.encode64(response.body))
      end
    end
  end
end
