# frozen_string_literal: true

module V1
  # Defines the Investors controller
  class InvestorsController < ApplicationController
    include DocumentBuilder

    before_action :authenticate_user!

    def filled_fund_subscription_agreement
      investor = Investor.find(params.require(:id))
      authorize investor, :show?

      template = investor.fund.subscription_agreement_template
      context = investor.subscription_agreement_context
      send_filled_template(template, context)
    end

    def filled_fund_quarterly_report
      investor = Investor.find(params.require(:id))
      fund_report = FundReport.find(params.require(:fund_report_id))
      authorize investor, :show?
      authorize fund_report, :show?

      template = investor.fund.quarterly_report_template
      context = investor.quarterly_report_context(fund_report)
      send_filled_template(template, context)
    end
  end
end
