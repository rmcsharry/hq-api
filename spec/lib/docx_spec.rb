# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Docx::Document, type: :util do
  let(:file) { File.open(Rails.root.join('spec', 'fixtures', 'docx', document_name)) }

  describe 'document parsing' do
    context 'with a zoomed and scrolled template' do
      let(:document_name) { 'zoomed_scrolled.docx' }
      it 'resets the zoom setting to 100%' do
        document = Docx::Document.new(file)
        document.commit({})

        tempfile = Tempfile.new
        tempfile.binmode
        tempfile.write document.render
        rendered_document = Docx::Document.new(tempfile)
        rendered_document.render
        tempfile.close

        settings = rendered_document.documents['word/settings.xml']
        zoom_node = settings.xpath('//w:zoom').first
        expect(zoom_node.attr('w:percent')).to eq('100')
      end
    end

    context 'with an invalid conditional' do
      let(:document_name) { 'invalid_conditional.docx' }
      it 'fails gracefully' do
        document = Docx::Document.new(file)
        expect do
          document.commit({})
        end.to raise_error(Docx::RenderError, /Could not find end field/)
      end
    end

    context 'with an invalid condition' do
      let(:document_name) { 'invalid_condition.docx' }
      it 'fails gracefully' do
        document = Docx::Document.new(file)
        expect do
          document.commit({})
        end.to raise_error(Docx::RenderError, /Failed executing operation/)
      end
    end

    context 'with `Ausschuettung` template' do
      let(:document_name) { 'Ausschuettung_Vorlage.docx' }

      it 'properly parses the template' do
        document = Docx::Document.new(file)
        document.commit(
          current_date: '24.12.2018',
          investor: {
            amount_total: 421_337,
            primary_owner: {
              full_name: 'Test Name 123'
            }
          },
          investor_cashflow: {
            capital_call_management_fees_amount: 0,
            capital_call_management_fees_percentage: 0,
            capital_call_compensatory_interest_amount: 0,
            capital_call_compensatory_interest_percentage: 0,
            capital_call_gross_amount: 0,
            capital_call_gross_percentage: 0,
            capital_call_total_amount: 0,
            capital_call_total_percentage: 0,
            distribution_compensatory_interest_amount: 0,
            distribution_compensatory_interest_percentage: 0,
            distribution_dividends_amount: 0,
            distribution_dividends_percentage: 0,
            distribution_interest_amount: 0,
            distribution_interest_percentage: 0,
            distribution_misc_profits_amount: 0,
            distribution_misc_profits_percentage: 0,
            distribution_participation_profits_amount: 0,
            distribution_participation_profits_percentage: 0,
            distribution_recallable_amount: 0,
            distribution_recallable_percentage: 0,
            distribution_repatriation_amount: 0,
            distribution_repatriation_percentage: 0,
            distribution_structure_costs_amount: 0,
            distribution_structure_costs_percentage: 0,
            distribution_total_amount: 0,
            distribution_total_percentage: 0,
            distribution_withholding_tax_amount: 0,
            distribution_withholding_tax_percentage: 0,
            net_cashflow_amount: 0,
            net_cashflow_percentage: 0
          }
        )

        tempfile = Tempfile.new
        tempfile.binmode
        tempfile.write document.render
        rendered_document = Docx::Document.new(tempfile)
        tempfile.close

        content = rendered_document.to_s
        expect(content).to include('Test Name 123')
        expect(content).to include('421337')
        expect(content).to include('24.12.2018')
        expect(content).not_to match(/\{[a-z_\.]+\}/)
      end
    end

    context 'with `Quartalsbericht` template' do
      let(:document_name) { 'Quartalsbericht_Vorlage.docx' }

      it 'properly parses the template' do
        document = Docx::Document.new(file)

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
            description: Sablon.content(:word_ml, description.to_s)
          },
          investor: {
            amount_total: 1337,
            contact_address: {
              full_address: 'Visionsstr. 42, 10997, Berlin'
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
        rendered_document = Docx::Document.new(tempfile)
        tempfile.close

        content = rendered_document.to_s
        expect(content).to include('Fancy Foo Funds')
        expect(content).to include('Zeichnungsbetrag: 1337')
        expect(content).to include('Quill text here.')
        expect(content).to include('first list entry')
        expect(content).to include('second list entry')
      end
    end
  end
end
