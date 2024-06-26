# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe INVESTORS_ENDPOINT, type: :request do
  include ActiveJob::TestHelper

  let(:random_user) { create(:user) }
  let(:contact_person) do
    create(:contact_person, user: random_user)
  end
  let!(:mandate) { create(:mandate, :with_owner, owner: contact_person) }
  let!(:user) do
    create(
      :user,
      roles: %i[contacts_read funds_read mandates_read],
      permitted_mandates: [mandate]
    )
  end
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  describe 'GET /v1/investors' do
    let!(:investors) { create_list(:investor, 4, mandate: mandate) }

    context 'sort by joined associations' do
      subject do
        get(
          INVESTORS_ENDPOINT,
          params: {
            sort: sorting_param,
            page: { number: 1, size: 5 }
          },
          headers: auth_headers
        )
      end

      describe 'sort by mandate.owner_name', bullet: false do
        let(:sorting_param) { 'mandate.owner_name' }

        it 'also returns all investors' do
          subject
          expect(response).to have_http_status(200)
          body = JSON.parse(response.body)
          expect(body.keys).to include 'data', 'meta', 'links'
          expect(body['data'].count).to eq 4
          expect(body['meta']['record-count']).to eq 4
        end
      end
    end
  end

  [
    'fund-subscription-agreement-document',
    'regenerated-fund-subscription-agreement-document'
  ].each do |action|
    describe "GET /v1/investors/:id/#{action}" do
      let(:primary_contact) { create(:contact_person) }
      let(:secondary_contact) { create(:contact_person) }
      let!(:mandate_member1) do
        create(:mandate_member, mandate: mandate, contact: primary_contact, member_type: :assistant)
      end
      let!(:mandate_member2) do
        create(:mandate_member, mandate: mandate, contact: secondary_contact, member_type: :bookkeeper)
      end
      let!(:fund) { create(:fund) }
      let!(:investor) do
        create(
          :investor,
          fund: fund,
          mandate: mandate.reload
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
          "#{INVESTORS_ENDPOINT}/#{investor.id}/#{action}",
          params: {},
          headers: auth_headers
        )

        tempfile = Tempfile.new 'filled-agreement'
        tempfile.binmode
        tempfile.write response.body
        @response_document = Docx::Document.new(tempfile) unless File.zero?(tempfile)
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

      context 'with missing owner, contacts and addresses on mandate' do
        let(:document_name) { 'Zeichnungsschein_Vorlage.docx' }

        let!(:mandate) { create(:mandate) }

        it 'downloads the (only partially) filled template' do
          expect(investor.primary_owner).to be_nil
          expect(investor.primary_contact).to be_nil
          expect(investor.secondary_contact).to be_nil
          expect(investor.legal_address).to be_nil
          expect(investor.contact_address).to be_nil

          expect(response).to have_http_status(201)
          content = @response_document.to_s

          expect(content).to include(fund.name)

          # Check that there are no un-replaced templating tokens
          expect(content).not_to match(/\{[a-z_\.]+\}/)
        end
      end
    end
  end
end
