# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Docx::Document, type: :util do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'docx', document_name) }

  describe 'document parsing' do
    context 'with actual template' do
      let(:document_name) { '20181219-Ausschuettung_Vorlage.docx' }

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
  end
end
