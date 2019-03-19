# frozen_string_literal: true

module V1
  # Defines the FundReports controller
  class FundReportsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def archived_documents
      fund_report = FundReport
                    .includes(:fund, investors: %i[contact_address mandate])
                    .find(params.require(:id))
      authorize fund_report, :show?

      send_archive quarterly_report_document_map(fund_report), fund_report.archive_name
    end

    private

    def quarterly_report_document_map(fund_report)
      fund_report.investor_reports.each_with_object({}) do |investor_report, documents|
        file = investor_report.quarterly_report_document(current_user).file
        documents[file.filename] = file.download
      end
    end
  end
end
