# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Docx::Document, type: :util do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'docx', document_name) }

  describe 'document parsing' do
    context 'with `Ausschuettung` template' do
      let(:document_name) { '20190122-Ausschuettung_Vorlage.docx' }

      it 'properly parses the template' do
        document = Docx::Document.new(file_path)
        document.commit(
          current_date: '24.12.2018',
          investor: {
            amount_total: 421_337,
            primary_owner: {
              full_name: 'Test Name 123'
            }
          }
        )

        tempfile = Tempfile.new
        tempfile.binmode
        tempfile.write document.render
        rendered_document = Docx::Document.new(tempfile.path)
        tempfile.close

        content = rendered_document.to_s
        expect(content).to include('Test Name 123')
        expect(content).to include('421337')
        expect(content).to include('24.12.2018')
        expect(content).not_to match(/\{[a-z_\.]+\}/)
      end
    end

    context 'with `Quartalsbericht` template' do
      let(:document_name) { '20181219-Quartalsbericht_Vorlage.docx' }

      it 'properly parses the template' do
        document = Docx::Document.new(file_path)

        description = Quill::Delta.new <<-QUILL.squish
          {
            "ops": [
              { "insert": "Quill", "attributes": { "bold": true } },
              { "insert": " text " },
              { "insert": "here.", "attributes": { "italic": true } },
              { "insert": " text\\nfirst list entry" },
              { "insert": "\\n", "attributes": { "list": "bullet" } },
              { "insert": "second list entry" },
              { "insert": "\\n", "attributes": { "list": "bullet" } }
            ]
          }
        QUILL

        document.commit(
          current_date: '01.01.2019',
          fund: {
            currency: 'EUR',
            name: 'Fancy Foo Funds'
          },
          fund_report: {
            description: description.to_s
          },
          investor: {
            amount_total: 1337,
            contact_address: {
              city: 'Berlin',
              postal_code: 10_997,
              street_and_number: 'Visionsstr. 42'
            },
            primary_owner: {
              formal_salutation: 'Sehr geehrter Herr',
              full_name: 'Donald Knuth',
              gender: 'Herr'
            }
          }
        )

        tempfile = Tempfile.new
        tempfile.binmode
        tempfile.write document.render
        rendered_document = Docx::Document.new(tempfile.path)
        tempfile.close

        content = rendered_document.to_s
        expect(content).to include('Zeichnungsbetrag: 1337')
        expect(content).to include('Quill text here.')
        expect(content).to include('first list entry')
        expect(content).to include('second list entry')
      end
    end
  end
end