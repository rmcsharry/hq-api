# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe FUND_REPORTS_ENDPOINT, type: :request do
  let!(:user) { create(:user, roles: %i[funds_read funds_write]) }
  let(:headers) { { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }

  [
    'archived-documents',
    'regenerated-documents'
  ].each do |action|
    describe "GET /v1/fund-reports/:id/#{action}", bullet: false do
      let(:fund) { create(:fund, name: 'Fund') }
      let(:contact_person1) { create(:contact_person, first_name: 'First', last_name: 'Last') }
      let(:contact_person2) { create(:contact_person, first_name: 'Fore', last_name: 'Family') }
      let(:mandate1) { create(:mandate, :with_owner, owner: contact_person1) }
      let(:mandate2) { create(:mandate, :with_owner, owner: contact_person2) }
      let(:investor1) { create(:investor, :signed, fund: fund, mandate: mandate1) }
      let(:investor2) { create(:investor, :signed, fund: fund, mandate: mandate2) }
      let(:fund_report) do
        create(:fund_report, fund: fund, valuta_date: Date.new(2019, 3, 1))
      end
      let!(:investor_report1) { create(:investor_report, fund_report: fund_report, investor: investor1) }
      let!(:investor_report2) { create(:investor_report, fund_report: fund_report, investor: investor2) }
      let!(:document) do
        doc = create(
          :fund_template_document,
          category: :fund_quarterly_report_template,
          owner: fund
        )
        doc.file.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'docx', 'Quartalsbericht_Vorlage.docx')),
          filename: 'report.docx',
          content_type: Mime[:docx].to_s
        )
        doc
      end

      before do
        get(
          "#{FUND_REPORTS_ENDPOINT}/#{fund_report.id}/#{action}",
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
                "190301_Quartalsbericht_Fund_Family, Fore und Guntersen, Thomas_#{investor_report2.id[0..7]}.docx",
                "190301_Quartalsbericht_Fund_Guntersen, Thomas und Last, First_#{investor_report1.id[0..7]}.docx"
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
        let(:primary_owner) { create(:contact_person) }

        it 'returns zip containing unmodified pdf documents' do
          expected_document = File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')).read

          expect(@response_archive.size).to eq(2)
          file_names = @response_archive.entries.map { |e| e.name.force_encoding('UTF-8') }
          expect(file_names).to(
            match_array(
              [
                "190301_Quartalsbericht_Fund_Family, Fore und Guntersen, Thomas_#{investor_report2.id[0..7]}.pdf",
                "190301_Quartalsbericht_Fund_Guntersen, Thomas und Last, First_#{investor_report1.id[0..7]}.pdf"
              ]
            )
          )
          response_documents = @response_archive.entries.map do |entry|
            entry.get_input_stream.read
          end
          response_documents.each do |response_document|
            expect(Base64.encode64(expected_document)).to eq(Base64.encode64(response_document))
          end
        end
      end
    end
  end
end
