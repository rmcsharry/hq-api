# frozen_string_literal: true

module V1
  # Defines the InvestorReports controller
  class InvestorReportsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def quarterly_report_document
      investor_report = InvestorReport.includes(:investor, :fund_report).find(params.require(:id))
      investor = investor_report.investor
      fund_report = investor_report.fund_report
      authorize investor, :show?
      authorize fund_report, :show?

      send_attachment(
        investor_report.quarterly_report_document(current_user: current_user).file
      )
    end
  end
end
