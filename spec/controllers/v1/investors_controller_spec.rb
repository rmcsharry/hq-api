# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTORS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let(:random_user) { create(:user) }
  let(:contact_person) { create(:contact_person, user: random_user) }
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

  describe 'GET /v1/investors/:id/filled-fund-subscription-agreement', bullet: false do
    let!(:fund) { create(:fund) }
    let!(:investor) { create(:investor, fund: fund, mandate: mandate) }
    let!(:document) do
      doc = create(
        :fund_template_document,
        category: :fund_subscription_agreement_template,
        owner: fund
      )
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)),
        filename: 'hqtrust_sample_template.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end

    before do
      get("#{INVESTORS_ENDPOINT}/#{investor.id}/filled-fund-subscription-agreement", params: {}, headers: auth_headers)

      tempfile = Tempfile.new 'filled-agreement'
      tempfile.binmode
      tempfile.write response.body
      @response_document = Docx::Document.open(tempfile.path) unless File.zero?(tempfile)
      tempfile.close
    end

    describe 'with normal template' do
      let(:document_name) { 'hqtrust_sample_template.docx' }

      it 'downloads the filled template' do
        expect(response).to have_http_status(201)

        mandate = Mandate.with_owner_name.find(investor.mandate_id)
        expect(@response_document.paragraphs[0].to_s).to eq("Owner: #{mandate.owner_name}")
        expect(@response_document.paragraphs[1].to_s).to eq("Total amount: #{investor.amount_total}")
      end
    end

    describe 'with missing funds permissions' do
      let(:document_name) { 'hqtrust_sample_template.docx' }
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

    describe 'with missing mandate permissions' do
      let(:document_name) { 'hqtrust_sample_template.docx' }
      let!(:user) do
        create(
          :user,
          roles: %i[contacts_read mandates_read funds_read],
          permitted_mandates: []
        )
      end

      it 'receives a 403' do
        expect(response).to have_http_status(403)
      end
    end

    describe 'with malicious template' do
      let(:document_name) { 'hqtrust_sample_unprivileged_access.docx' }

      it 'does not receive the encrypted password' do
        expect(response).to have_http_status(201)

        expect(@response_document.paragraphs.first.to_s).not_to match(/Encrypted password: [a-zA-Z0-9\$]+/)
      end
    end
  end
end
