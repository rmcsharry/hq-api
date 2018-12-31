# frozen_string_literal: true

module V1
  # Defines the Investors controller
  class InvestorsController < ApplicationController
    include DocumentBuilder

    before_action :authenticate_user!

    def filled_fund_subscription_agreement
      investor = Investor.find(params.require(:id))
      authorize investor, :show?

      render_filled_template(
        fund_template(investor, :fund_subscription_agreement_template),
        fund_subscription_agreement_context(investor)
      )
    end

    def filled_fund_quarterly_report
      investor = Investor.find(params.require(:id))
      fund_report = FundReport.find(params.require(:fund_report_id))
      authorize investor, :show?
      authorize fund_report, :show?

      render_filled_template(
        fund_template(investor, :fund_quarterly_report_template),
        fund_quarterly_report_context(investor, fund_report)
      )
    end

    private

    def fund_template(investor, template_category)
      Document.find_by(
        owner_id: investor.fund_id,
        category: template_category
      )
    end

    def fund_subscription_agreement_context(investor)
      Document::FundTemplate.fund_subscription_agreement_context(
        investor: investor
      )
    end

    def fund_quarterly_report_context(investor, fund_report)
      Document::FundTemplate.fund_quarterly_report_context(
        investor: investor,
        fund_report: fund_report
      )
    end
  end
end
