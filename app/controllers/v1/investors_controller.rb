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
        fund_subscription_agreement_template(investor),
        fund_subscription_agreement_context(investor)
      )
    end

    private

    def fund_subscription_agreement_template(investor)
      Document.find_by(
        owner_id: investor.fund_id,
        category: :fund_subscription_agreement_template
      )
    end

    def fund_subscription_agreement_context(investor)
      mandate = Mandate.with_owner_name.find(investor.mandate_id)
      authorize mandate, :show?

      Document::FundTemplate.fund_subscription_agreement_context(
        investor: investor,
        mandate: mandate
      )
    end
  end
end
