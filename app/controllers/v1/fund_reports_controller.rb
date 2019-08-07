# frozen_string_literal: true

module V1
  # Defines the FundReports controller
  class FundReportsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def archived_documents
      download_documents
    end

    def regenerated_documents
      download_documents(regenerate: true)
    end

    private

    def download_documents(regenerate: false)
      fund_report = FundReport
                    .includes(:fund, investors: [mandate: [:contact_address]])
                    .find(params.require(:id))
      authorize fund_report, :show?

      send_archive(
        quarterly_report_document_map(fund_report: fund_report, regenerate: regenerate),
        fund_report.archive_name
      )
    end

    def quarterly_report_document_map(fund_report:, regenerate: false)
      fund_report.investor_reports.each_with_object({}) do |investor_report, documents|
        file = investor_report.quarterly_report_document(current_user: current_user, regenerate: regenerate).file
        documents[file.filename] = file.download
      end
    end
  end
end
