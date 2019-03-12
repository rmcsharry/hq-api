# frozen_string_literal: true

module V1
  # Defines the InvestorReport resource for the API
  class InvestorReportResource < BaseResource
    has_one :fund_report
    has_one :investor
  end
end
