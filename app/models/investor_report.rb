# frozen_string_literal: true

# == Schema Information
#
# Table name: investor_reports
#
#  fund_report_id :uuid
#  id             :uuid             not null, primary key
#  investor_id    :uuid
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

# Defines the join-model between fund-reports and investors
class InvestorReport < ApplicationRecord
  include GeneratedDocument

  belongs_to :fund_report
  belongs_to :investor

  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy

  has_paper_trail(
    meta: {
      parent_item_id: proc { |investor_report| investor_report.fund_report.fund_id },
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  def quarterly_report_document_context
    Document::FundTemplate.fund_quarterly_report_context(investor, fund_report)
  end

  def quarterly_report_document(current_user:, regenerate: false)
    transaction do
      template = investor.fund.quarterly_report_template
      clean_up_existing_quarterly_report if regenerate
      find_or_create_document(
        document_category: :generated_quarterly_report_document, name: quarterly_report_document_name(template),
        template: template, template_context: quarterly_report_document_context,
        uploader: current_user
      )
    end
  end

  private

  def clean_up_existing_quarterly_report
    document = find_generated_document_by_category(:generated_quarterly_report_document)
    document&.destroy!
  end

  def quarterly_report_document_name(template)
    extension = Docx.docx?(template.file) ? 'docx' : 'pdf'
    fund_identifier = fund_report.fund.name
    mandate_identifier = investor.mandate.decorate.owner_name
    date = fund_report.valuta_date.strftime('%y%m%d')
    "#{date}_Quartalsbericht_#{fund_identifier}_#{mandate_identifier}_#{id[0..7]}.#{extension}"
  end
end
