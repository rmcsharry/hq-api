# frozen_string_literal: true

# == Schema Information
#
# Table name: investor_reports
#
#  fund_report_id :uuid
#  investor_id    :uuid
#  id             :uuid             not null, primary key
#
# Indexes
#
#  index_investor_reports_on_fund_report_id  (fund_report_id)
#  index_investor_reports_on_investor_id     (investor_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_report_id => fund_reports.id)
#  fk_rails_...  (investor_id => investors.id)
#

require 'rails_helper'

RSpec.describe InvestorReport, type: :model do
  it { is_expected.to belong_to(:investor) }
  it { is_expected.to belong_to(:fund_report) }

  describe '#quarterly_report_document_context', bullet: false do
    let!(:investor_report) { create(:investor_report) }

    it 'returns the quarterly_report_document context' do
      expect(investor_report.quarterly_report_document_context.keys).to(
        match_array(
          %i[
            current_date
            fund
            fund_report
            investor
          ]
        )
      )
    end
  end

  describe '#quarterly_report_document', bullet: false do
    let(:current_user) { create(:user) }
    let(:fund) { create(:fund) }
    let!(:investor) { create(:investor, :signed, fund: fund) }
    let!(:fund_report) { create(:fund_report, fund: fund, investors: [investor]) }
    let!(:investor_report) { InvestorReport.find_by! investor: investor, fund_report: fund_report }
    let(:valid_template_name) { 'Quartalsbericht_Vorlage.docx' }
    let(:invalid_template_name) { 'hqtrust_sample_unprivileged_access.docx' }
    let!(:valid_template) do
      doc = create(
        :fund_template_document,
        category: :fund_quarterly_report_template,
        owner: fund
      )
      doc.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', valid_template_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      )
      doc
    end
    let!(:invalid_template_file) do
      {
        io: File.open(Rails.root.join('spec', 'fixtures', 'docx', invalid_template_name)),
        filename: 'sample.docx',
        content_type: Mime[:docx].to_s
      }
    end

    it 'is generated and persisted if absent' do
      generated_document = investor_report.quarterly_report_document(current_user)
      document_content = docx_document_content(generated_document.file.download)

      expect(document_content).to include(fund.name)

      valid_template.file.attach(invalid_template_file)
      subsequently_retrieved_document = investor_report.quarterly_report_document(current_user)
      subsequent_document_content = docx_document_content(subsequently_retrieved_document.file.download)

      expect(subsequent_document_content).to eq(document_content)
    end
  end
end
