# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTORS_ENDPOINT, type: :request do
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

  describe 'GET /v1/investors/:id/fund-subscription-agreement-document' do
    let(:primary_contact) { create(:contact_person) }
    let(:secondary_contact) { create(:contact_person) }
    let!(:mandate_member1) do
      create(:mandate_member, mandate: mandate, contact: primary_contact, member_type: :consultant)
    end
    let!(:mandate_member2) do
      create(:mandate_member, mandate: mandate, contact: secondary_contact, member_type: :consultant)
    end
    let!(:fund) { create(:fund) }
    let!(:investor) do
      create(
        :investor,
        fund: fund,
        mandate: mandate.reload,
        primary_contact: primary_contact.reload,
        primary_owner: contact_person.reload,
        secondary_contact: secondary_contact.reload
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
      get(
        "#{INVESTORS_ENDPOINT}/#{investor.id}/fund-subscription-agreement-document",
        params: {},
        headers: auth_headers
      )

      tempfile = Tempfile.new 'filled-agreement'
      tempfile.binmode
      tempfile.write response.body
      @response_document = Docx::Document.new(tempfile.path) unless File.zero?(tempfile)
      tempfile.close
    end

    context 'with actual template' do
      let(:document_name) { 'Zeichnungsschein_Vorlage.docx' }

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
      let(:document_name) { 'Zeichnungsschein_Vorlage.docx' }
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
end
