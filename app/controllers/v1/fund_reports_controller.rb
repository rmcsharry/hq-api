# frozen_string_literal: true

module V1
  # Defines the FundReports controller
  class FundReportsController < ApplicationController
    include DocumentBuilder

    before_action :authenticate_user!

    def archived_documents
      fund_report = FundReport
                    .includes(:fund, investors: %i[contact_address mandate])
                    .find(params.require(:id))
      authorize fund_report, :show?

      send_archive build_documents(fund_report)
    end

    private

    def build_documents(fund_report)
      template = fund_report.fund.quarterly_report_template
      is_docx = Docx.docx?(template.file)

      fund_report.investors.each_with_object({}) do |investor, documents|
        context = investor.quarterly_report_context(fund_report)
        name = document_name(fund_report, investor, is_docx)
        documents[name] = is_docx ? build_document(template, context) : template.file.download
      end
    end

    def document_name(fund_report, investor, is_docx)
      extension = is_docx ? 'docx' : 'pdf'
      fund_identifier = fund_report.fund.name
      mandate_identifier = investor.mandate.decorate.owner_name
      "Quartalsbericht_#{fund_identifier}_#{mandate_identifier}.#{extension}"
    end
  end
end
