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

      send_file build_document_archive(fund_report), 'application/zip'
    end

    private

    def build_document_archive(fund_report)
      template = fund_report.fund.quarterly_report_template

      Zip::OutputStream.write_buffer do |out|
        fund_report.investors.each do |investor|
          context = investor.quarterly_report_context(fund_report)
          out.put_next_entry(document_name(fund_report, investor))
          out.write(build_document(template, context))
        end
      end.string
    end

    def document_name(fund_report, investor)
      fund_identifier = fund_report.fund.name
      mandate_identifier = investor.mandate.decorate.owner_name
      "Quartalsbericht_#{fund_identifier}_#{mandate_identifier}.docx"
    end
  end
end
